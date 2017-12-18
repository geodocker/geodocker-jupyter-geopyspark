.PHONY: image clean cleaner cleanest mrproper

TAG ?= rpm
FAMILY := quay.io/geodocker/jupyter-geopyspark
AWSBUILD := $(FAMILY):aws-build-gdal-3
IMAGE := $(FAMILY):$(TAG)
GEOPYSPARK_SHA ?= a5ec919c53e1ae083b2d7284e9053e7173b6bfae
GEOPYSPARK_NETCDF_SHA ?= 69897d9f03df2efbf6f7d8317aa6ad004274b1eb
GEONOTEBOOK_SHA ?= 2c0073c60afc610f7d9616edbb3843e5ba8b68af
GEOPYSPARK_VERSION ?= 0.2.2
GEOPYSPARK_JAR := geotrellis-backend-assembly-$(GEOPYSPARK_VERSION).jar
PYTHON_BLOB1 := friends-of-geopyspark.tar.gz
PYTHON_BLOB2 := geopyspark-sans-friends.tar.gz

all: image

archives/geopyspark-$(GEOPYSPARK_SHA).zip:
	curl -L "https://github.com/locationtech-labs/geopyspark/archive/$(GEOPYSPARK_SHA).zip" -o $@

archives/geonotebook-$(GEONOTEBOOK_SHA).zip:
	curl -L "https://github.com/geotrellis/geonotebook/archive/$(GEONOTEBOOK_SHA).zip" -o $@

archives/geopyspark-netcdf-$(GEOPYSPARK_NETCDF_SHA).zip:
	curl -L "https://github.com/geotrellis/geopyspark-netcdf/archive/$(GEOPYSPARK_NETCDF_SHA).zip" -o $@

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
	rm -rf scratch/pip-cache/wheels/*
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scratch/dot-local:/root/.local:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(AWSBUILD) /scripts/build-python-blob2.sh $(shell id -u) $(shell id -g) $(PYTHON_BLOB2) $(GEOPYSPARK_SHA) $(GEOPYSPARK_NETCDF_SHA)

########################################################################

image: Dockerfile \
   blobs/geonotebook-$(GEONOTEBOOK_SHA).zip \
   blobs/$(GEOPYSPARK_JAR) \
   blobs/$(GEOPYSPARK-WHEEL) \
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
env:
	env

clean:
	rm -f archives/$(GEOPYSPARK_JAR)
	rm -rf scratch/local/gdal/

cleaner: clean
	rm -f blobs/*
	rm -rf geopyspark-*/
	rm -rf scratch/dot-local/*

cleanest: cleaner
	rm -rf scratch/local/src

mrproper: cleanest
	rm -rf archives/*
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
          -p 8000:8000 -p 4040:4040 \
          $(EXTRA_FLAGS) \
          -v $(shell pwd)/notebooks:/home/hadoop/notebooks:rw \
          -v $(HOME)/.aws:/home/hadoop/.aws:ro \
          $(IMAGE)

run-editable:
	mkdir -p $(HOME)/.aws
	docker run -it --rm --name geopyspark \
          -p 8000:8000 -p 4040:4040 \
          $(EXTRA_FLAGS) \
          -v $(GEOPYSPARK_DIR):/home/hadoop/.local/lib/python3.4/site-packages/geopyspark:rw \
          -v $(shell pwd)/notebooks:/home/hadoop/notebooks:rw \
          -v $(HOME)/.aws:/home/hadoop/.aws:ro \
          $(IMAGE)

shell:
	docker exec -it geopyspark bash
