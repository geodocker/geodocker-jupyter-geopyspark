.PHONY: stage0 stage2 all clean cleaner cleanest mrproper build

TAG ?= 16
IMG := quay.io/geodocker/jupyter-geopyspark
STAGE0 := jamesmcclain/jupyter-geopyspark:stage0
STAGE1 := $(IMG):80da618
STAGE2 := $(IMG):$(TAG)
GEOPYSPARK_SHA ?= 133ce7bb5f085a2561f18ec6d7ebe1e4037dae89
GEOPYSPARK_NETCDF_SHA ?= 803b0b64a43255644d34a5a162be59250c4cc836
GEONOTEBOOK_SHA ?= 033a86d89fed4e0add0fd20a04f23e738e05e304
GEOPYSPARK_VERSION ?= 0.2.0
GEOPYSPARK-JAR := geotrellis-backend-assembly-$(GEOPYSPARK_VERSION).jar
PYTHON_BLOB1 := friends-of-geopyspark.tar.gz
PYTHON_BLOB2 := geopyspark-sans-friends.tar.gz
SRC := archives/gdal-2.1.3.tar.gz archives/geos-3.6.1.tar.bz2 archives/lcms2-2.8.tar.gz archives/libpng-1.6.28.tar.gz archives/proj-4.9.3.tar.gz archives/openjpeg-v2.1.2.tar.gz archives/zlib-1.2.11.tar.gz
GDAL_BLOB := gdal-and-friends.tar.gz
CDM_JAR := netcdfAll-5.0.0-SNAPSHOT.jar
NETCDF_JAR := gddp-assembly-$(GEOPYSPARK_VERSION).jar


all: stage0 stage2

archives/zlib-1.2.11.tar.gz:
	curl -L "https://downloads.sourceforge.net/project/libpng/zlib/1.2.11/zlib-1.2.11.tar.gz?r=http%3A%2F%2Fwww.zlib.net%2F&ts=1490316463&use_mirror=pilotfiber" -o $@

archives/libpng-1.6.28.tar.gz:
	curl -L "https://downloads.sourceforge.net/project/libpng/libpng16/1.6.28/libpng-1.6.28.tar.gz?r=http%3A%2F%2Fwww.libpng.org%2Fpub%2Fpng%2Flibpng.html&ts=1490316660&use_mirror=superb-sea2" -o $@

archives/geos-3.6.1.tar.bz2:
	curl -L "http://download.osgeo.org/geos/geos-3.6.1.tar.bz2" -o $@

archives/proj-4.9.3.tar.gz:
	curl -L "http://download.osgeo.org/proj/proj-4.9.3.tar.gz" -o $@

archives/lcms2-2.8.tar.gz:
	curl -L "https://downloads.sourceforge.net/project/lcms/lcms/2.8/lcms2-2.8.tar.gz?r=&ts=1490316968&use_mirror=pilotfiber" -o $@

archives/openjpeg-v2.1.2.tar.gz:
	curl -L "https://github.com/uclouvain/openjpeg/archive/v2.1.2.tar.gz" -o $@

archives/gdal-2.1.3.tar.gz:
	curl -L "http://download.osgeo.org/gdal/2.1.3/gdal-2.1.3.tar.gz" -o $@

archives/geopyspark-$(GEOPYSPARK_SHA).zip:
	curl -L "https://github.com/locationtech-labs/geopyspark/archive/$(GEOPYSPARK_SHA).zip" -o $@

archives/geonotebook-$(GEONOTEBOOK_SHA).zip:
	curl -L "https://github.com/geotrellis/geonotebook/archive/$(GEONOTEBOOK_SHA).zip" -o $@

archives/geopyspark-netcdf-$(GEOPYSPARK_NETCDF_SHA).zip:
	curl -L "https://github.com/geotrellis/geopyspark-netcdf/archive/$(GEOPYSPARK_NETCDF_SHA).zip" -o $@

archives/s3+hdfs.zip:
	curl -L "https://github.com/Unidata/thredds/archive/feature/s3+hdfs.zip" -o $@

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

blobs/%: archives/%
	cp -f $< $@

stage0: Dockerfile.stage0
	(docker pull $(STAGE0)) || (build -t $(STAGE0) -f Dockerfile.stage0 .)

ifeq ($(TRAVIS),1)
archives/$(GDAL_BLOB):
	docker pull $(STAGE1)
	docker run -it --rm -u root \
          -v $(shell pwd)/archives:/archives:rw \
          $(STAGE1) /scripts/extract-blob.sh $(shell id -u) $(shell id -g) $(GDAL_BLOB)
	docker rmi $(STAGE1)

scratch/local/gdal: $(shell .travis/not.sh archives/$(GDAL_BLOB))
	rm -rf scratch/local/gdal
	mkdir -p scratch/local/gdal
	(cd scratch/local/gdal ; tar axf ../../../archives/$(GDAL_BLOB))

else
archives/$(GDAL_BLOB) scratch/local/gdal: $(SRC) scripts/build-native-blob.sh
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scratch/local:/root/local:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(STAGE0) /scripts/build-native-blob.sh $(shell id -u) $(shell id -g)
endif

archives/$(PYTHON_BLOB1) scratch/dot-local/lib/python3.4/site-packages/.xxx: scripts/build-python-blob1.sh scratch/local/gdal
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scratch/dot-local:/root/.local:rw \
          -v $(shell pwd)/scratch/local:/root/local:ro \
          -v $(shell pwd)/scratch/pip-cache:/root/.cache/pip:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(STAGE0) /scripts/build-python-blob1.sh $(shell id -u) $(shell id -g) $(PYTHON_BLOB1)

archives/$(PYTHON_BLOB2): scripts/build-python-blob2.sh scratch/dot-local/lib/python3.4/site-packages/.xxx archives/geopyspark-$(GEOPYSPARK_SHA).zip archives/geopyspark-netcdf-$(GEOPYSPARK_NETCDF_SHA).zip
	rm -rf scratch/dot-local/lib/python3.4/site-packages/geopyspark*
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scratch/dot-local:/root/.local:rw \
          -v $(shell pwd)/scratch/local:/root/local:ro \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(STAGE0) /scripts/build-python-blob2.sh $(shell id -u) $(shell id -g) $(PYTHON_BLOB2) $(GEOPYSPARK_SHA) $(GEOPYSPARK_NETCDF_SHA)

%: archives/%.zip
	rm -rf $@
	unzip -qu $<

archives/$(GEOPYSPARK-JAR): geopyspark-$(GEOPYSPARK_SHA)
	make -C $< build
	cp -f $</geopyspark/jars/$(GEOPYSPARK-JAR) $@

ifeq ($(TRAVIS),1)
archives/$(NETCDF_JAR): geopyspark-netcdf-$(GEOPYSPARK_NETCDF_SHA) $(shell .travis/not.sh archives/$(CDM_JAR)) archives/$(GEOPYSPARK-JAR)
else
archives/$(NETCDF_JAR): geopyspark-netcdf-$(GEOPYSPARK_NETCDF_SHA) archives/$(CDM_JAR) archives/$(GEOPYSPARK-JAR)
endif
	CDM_JAR_DIR=$(shell pwd)/archives GEOPYSPARK_JAR_DIR=$(shell pwd)/archives make -C $< backend/gddp/target/scala-2.11/$(NETCDF_JAR)
	cp -f $</backend/gddp/target/scala-2.11/$(NETCDF_JAR) $@

stage2: Dockerfile.stage2 blobs/geonotebook-$(GEONOTEBOOK_SHA).zip blobs/$(GEOPYSPARK-JAR) blobs/$(GEOPYSPARK-WHEEL) blobs/$(NETCDF_JAR) blobs/$(GDAL_BLOB) blobs/$(PYTHON_BLOB1) blobs/$(PYTHON_BLOB2)
ifeq ($(TRAVIS),1)
	docker rmi $(STAGE0)
	rm -rf $(shell ls archives/* | grep -iv '\(gdal-and-friends\|netcdf\)')
	rm -rf geopyspark-*/ scratch/local/
endif
	docker build \
          --build-arg VERSION=$(GEOPYSPARK_VERSION) \
          --build-arg GEONOTEBOOKSHA=$(GEONOTEBOOK_SHA) \
          --build-arg GDALBLOB=$(GDAL_BLOB) \
          --build-arg PYTHONBLOB1=$(PYTHON_BLOB1) \
          --build-arg PYTHONBLOB2=$(PYTHON_BLOB2) \
          -t $(STAGE2) -f Dockerfile.stage2 .

clean:
	(cd geopyspark-netcdf-$(GEOPYSPARK_NETCDF_SHA) ; ./sbt "project gddp" clean ; cd ..)
	rm -f archives/$(GDAL_BLOB)
	rm -f archives/$(GEOPYSPARK-JAR)
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

publish: build
	docker tag $(STAGE2) "$(IMG):latest"
	docker push $(STAGE2)
	docker push "$(IMG):latest"

#################################

GEOPYSPARK_DIR ?= $(realpath ../geopyspark/geopyspark)


run:
	mkdir -p $(HOME)/.aws
	docker run -it --rm --name geopyspark \
					-p 4040:4040 \
          -p 8000:8000 \
          $(EXTRA_FLAGS) \
          -v $(shell pwd)/notebooks:/home/hadoop/notebooks:rw \
          -v $(HOME)/.aws:/home/hadoop/.aws:ro \
          $(STAGE2)

run-editable:
	mkdir -p $(HOME)/.aws
	docker run -it --rm --name geopyspark \
          -p 8000:8000 \
          $(EXTRA_FLAGS) \
          -v $(GEOPYSPARK_DIR):/home/hadoop/.local/lib/python3.4/site-packages/geopyspark:rw \
          -v $(shell pwd)/notebooks:/home/hadoop/notebooks:rw \
          -v $(HOME)/.aws:/home/hadoop/.aws:ro \
          $(STAGE2)

shell:
	docker exec -it geopyspark bash
