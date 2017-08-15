.PHONY: image clean cleaner cleanest mrproper

TAG ?= mapnik
FAMILY := quay.io/geodocker/jupyter-geopyspark
AWSBUILD := $(FAMILY):aws-build-gdal-0
IMAGE := $(FAMILY):$(TAG)
GEOPYSPARK_SHA ?= bdc752e589e365f8d81912e08db936ffb5d689a1
GEOPYSPARK_NETCDF_SHA ?= 3f18ff9c9613932b4dc10e12ea9a1338260a3ff6
GEONOTEBOOK_SHA ?= 542d6c677c794b68f7ba0762d30650e995d82b2b
GEOPYSPARK_VERSION ?= 0.2.0
GEOPYSPARK_JAR := geotrellis-backend-assembly-$(GEOPYSPARK_VERSION).jar
PYTHON_BLOB1 := friends-of-geopyspark.tar.gz
PYTHON_BLOB2 := geopyspark-sans-friends.tar.gz
CDM_JAR := netcdfAll-5.0.0-SNAPSHOT.jar
NETCDF_JAR := gddp-assembly-$(GEOPYSPARK_VERSION).jar

all: image

archives/geopyspark-$(GEOPYSPARK_SHA).zip:
	curl -L "https://github.com/locationtech-labs/geopyspark/archive/$(GEOPYSPARK_SHA).zip" -o $@

archives/geonotebook-$(GEONOTEBOOK_SHA).zip:
	curl -L "https://github.com/jpolchlo/geonotebook/archive/$(GEONOTEBOOK_SHA).zip" -o $@

archives/geopyspark-netcdf-$(GEOPYSPARK_NETCDF_SHA).zip:
	curl -L "https://github.com/geotrellis/geopyspark-netcdf/archive/$(GEOPYSPARK_NETCDF_SHA).zip" -o $@

archives/s3+hdfs.zip:
	curl -L "https://github.com/Unidata/thredds/archive/feature/s3+hdfs.zip" -o $@

########################################################################

ifeq ($(TRAVIS),1)
thredds-feature-s3-hdfs: archives/s3+hdfs.zip
	unzip -qu $<

archives/$(CDM_JAR): thredds-feature-s3-hdfs
	(cd $< ; ./gradlew assemble > /dev/null 2>&1)
	cp -f $</build/libs/$(CDM_JAR) $@

else
archives/$(CDM_JAR): scripts/netcdf.sh archives/s3+hdfs.zip
	docker run -it --rm \
           -v $(shell pwd)/archives:/archives:rw \
           -v $(shell pwd)/scripts:/scripts:ro \
           -v $(HOME)/.m2:/root/.m2:rw \
           -v $(HOME)/.gradle:/root/.gradle:rw \
           openjdk:8-jdk /scripts/netcdf.sh $(shell id -u) $(shell id -g) $(CDM_JAR)
endif

########################################################################

blobs/%: archives/%
	cp -f $< $@

%: archives/%.zip
	rm -rf $@
	unzip -qu $<

########################################################################

archives/$(PYTHON_BLOB1) scratch/dot-local/lib/python3.4/site-packages/.xxx: scripts/build-python-blob1.sh
	rm -rf scratch/dot-local/lib/python3.4/site-packages/*
	rm -rf scratch/pip-cache/wheels/*
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scratch/dot-local:/root/.local:rw \
          -v $(shell pwd)/scratch/pip-cache:/root/.cache/pip:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(AWSBUILD) /scripts/build-python-blob1.sh $(shell id -u) $(shell id -g) $(PYTHON_BLOB1)

archives/$(PYTHON_BLOB2): scripts/build-python-blob2.sh scratch/dot-local/lib/python3.4/site-packages/.xxx \
   archives/geopyspark-$(GEOPYSPARK_SHA).zip \
   archives/geopyspark-netcdf-$(GEOPYSPARK_NETCDF_SHA).zip
	rm -rf scratch/dot-local/lib/python3.4/site-packages/geopyspark*
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scratch/dot-local:/root/.local:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(AWSBUILD) /scripts/build-python-blob2.sh $(shell id -u) $(shell id -g) $(PYTHON_BLOB2) $(GEOPYSPARK_SHA) $(GEOPYSPARK_NETCDF_SHA)

########################################################################

archives/$(GEOPYSPARK_JAR): geopyspark-$(GEOPYSPARK_SHA)
	make -C $< build
	cp -f $</geopyspark/jars/$(GEOPYSPARK_JAR) $@

########################################################################

ifeq ($(TRAVIS),1)
archives/$(NETCDF_JAR): geopyspark-netcdf-$(GEOPYSPARK_NETCDF_SHA) $(shell .travis/not.sh archives/$(CDM_JAR)) archives/$(GEOPYSPARK_JAR)
else
archives/$(NETCDF_JAR): geopyspark-netcdf-$(GEOPYSPARK_NETCDF_SHA) archives/$(CDM_JAR) archives/$(GEOPYSPARK_JAR)
endif
	CDM_JAR_DIR=$(shell pwd)/archives GEOPYSPARK_JAR_DIR=$(shell pwd)/archives make -C $< backend/gddp/target/scala-2.11/$(NETCDF_JAR)
	cp -f $</backend/gddp/target/scala-2.11/$(NETCDF_JAR) $@

########################################################################

image: Dockerfile \
   blobs/geonotebook-$(GEONOTEBOOK_SHA).zip \
   blobs/$(GEOPYSPARK_JAR) \
   blobs/$(GEOPYSPARK-WHEEL) \
   blobs/$(NETCDF_JAR) \
   blobs/$(PYTHON_BLOB1) \
   blobs/$(PYTHON_BLOB2)
ifeq ($(TRAVIS),1)
	docker rmi $(AWSBUILD)
	rm -rf $(shell ls archives/* | grep -iv 'netcdf')
	rm -rf geopyspark-*/ scratch/local/
endif
	docker build \
          --build-arg VERSION=$(GEOPYSPARK_VERSION) \
          --build-arg GEONOTEBOOKSHA=$(GEONOTEBOOK_SHA) \
          --build-arg PYTHONBLOB1=$(PYTHON_BLOB1) \
          --build-arg PYTHONBLOB2=$(PYTHON_BLOB2) \
          -t $(IMAGE) -f Dockerfile .

########################################################################

clean:
	rm -f archives/$(GEOPYSPARK_JAR)
	rm -rf scratch/local/gdal/

cleaner: clean
	rm -f archives/$(NETCDF_JAR)
	rm -f blobs/*
	rm -rf geopyspark-*/
	rm -rf scratch/dot-local/*

cleanest: cleaner
	rm -rf archives/$(CDM_JAR)
	rm -rf scratch/local/src

mrproper: cleanest
	rm -rf archives/*
	rm -rf scratch/dot-local/*
	rm -rf scratch/pip-cache/*

publish:
	docker tag $(IMAGE) "$(FAMILY):latest"
	docker push $(IMAGE)
	docker push "$(FAMILY):latest"

########################################################################

GEOPYSPARK_DIR ?= $(realpath ../geopyspark/geopyspark)

run:
	mkdir -p $(HOME)/.aws
	docker run -it --rm --name geopyspark \
          -p 8000:8000 \
          $(EXTRA_FLAGS) \
          -v $(shell pwd)/notebooks:/home/hadoop/notebooks:rw \
          -v $(HOME)/.aws:/home/hadoop/.aws:ro \
          $(IMAGE)

run-editable:
	mkdir -p $(HOME)/.aws
	docker run -it --rm --name geopyspark \
          -p 8000:8000 \
          $(EXTRA_FLAGS) \
          -v $(GEOPYSPARK_DIR):/home/hadoop/.local/lib/python3.4/site-packages/geopyspark:rw \
          -v $(shell pwd)/notebooks:/home/hadoop/notebooks:rw \
          -v $(HOME)/.aws:/home/hadoop/.aws:ro \
          $(IMAGE)

shell:
	docker exec -it geopyspark bash
