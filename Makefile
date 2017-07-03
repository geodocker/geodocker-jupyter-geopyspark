.PHONY: stage0 stage2 all clean cleaner cleanest mrproper build

N ?= 33
TAG ?= 13
STAGE0 := jamesmcclain/jupyter-geopyspark:stage0
STAGE1 := jamesmcclain/jupyter-geopyspark:13
IMG := quay.io/geodocker/jupyter-geopyspark
STAGE2 := $(IMG):$(TAG)
GEOPYSPARK-SHA ?= 3ff76fd9d332732c718fd884451a4768995dc308
GEONOTEBOOK-SHA ?= 5ea686af9d38a87dbf7a46c2575b71889856e2b2
GEOPYSPARK-VERSION ?= 0.1.0
GEOPYSPARK-WHEEL := geopyspark-$(GEOPYSPARK-VERSION)-py3-none-any.whl
GEOPYSPARK-JAR := geotrellis-backend-assembly-$(GEOPYSPARK-VERSION).jar
PYTHON-BLOB := geopyspark-and-friends.tar.gz
SRC := archives/gdal-2.1.3.tar.gz archives/geos-3.6.1.tar.bz2 archives/lcms2-2.8.tar.gz archives/libpng-1.6.28.tar.gz archives/proj-4.9.3.tar.gz archives/openjpeg-v2.1.2.tar.gz archives/zlib-1.2.11.tar.gz
GDAL-BLOB := gdal-and-friends.tar.gz
CDM-JAR := netcdfAll-5.0.0-SNAPSHOT.jar
NETCDF-JAR := gddp-assembly-$(GEOPYSPARK-VERSION).jar
rwildcard=$(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d))


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

archives/geopyspark-$(GEOPYSPARK-SHA).zip:
	curl -L "https://github.com/locationtech-labs/geopyspark/archive/$(GEOPYSPARK-SHA).zip" -o $@

archives/geonotebook-$(GEONOTEBOOK-SHA).zip:
	curl -L "https://github.com/geotrellis/geonotebook/archive/$(GEONOTEBOOK-SHA).zip" -o $@

archives/s3+hdfs.zip:
	curl -L "https://github.com/Unidata/thredds/archive/feature/s3+hdfs.zip" -o $@

archives/$(CDM-JAR): scripts/netcdf.sh archives/s3+hdfs.zip
	docker run -it --rm \
           -v $(shell pwd)/archives:/archives:rw \
           -v $(shell pwd)/scripts:/scripts:ro \
           -v $(HOME)/.m2:/root/.m2:rw \
           -v $(HOME)/.gradle:/root/.gradle:rw \
           openjdk:8-jdk /scripts/netcdf.sh $(shell id -u) $(shell id -g) $(CDM-JAR)
ifeq ($(TRAVIS),1)
	docker rmi "openjdk:8-jdk"
endif

archives/$(NETCDF-JAR): archives/$(CDM-JAR) archives/$(GEOPYSPARK-JAR) $(call rwildcard, netcdf-backend/, *.scala)
	cp -f archives/$(CDM-JAR) archives/$(GEOPYSPARK-JAR) /tmp
	(cd netcdf-backend; ./sbt "project gddp" assembly; cd ..)
	cp -f netcdf-backend/gddp/target/scala-2.11/$(NETCDF-JAR) $@
	rm -f /tmp/$(CDM-JAR) /tmp/$(GEOPYSPARK-JAR)

blobs/%: archives/%
	cp -f $< $@

stage0: Dockerfile.stage0
	(docker pull $(STAGE0)) || (build -t $(STAGE0) -f Dockerfile.stage0 .)

ifeq ($(TRAVIS),1)
archives/$(GDAL-BLOB) scratch/local/gdal:
	rm -rf scratch/local/gdal
	docker pull $(STAGE1)
	docker run -it --rm -u root \
          -v $(shell pwd)/archives:/archives:rw \
          $(STAGE1) /scripts/extract-blob.sh $(shell id -u) $(shell id -g) $(GDAL-BLOB)
	docker rmi $(STAGE1)
	mkdir -p scratch/local/gdal
	(cd scratch/local/gdal ; tar axf ../../../archives/$(GDAL-BLOB))
else
archives/$(GDAL-BLOB) scratch/local/gdal: $(SRC) scripts/build-native-blob.sh
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scratch/local:/root/local:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(STAGE0) /scripts/build-native-blob.sh $(shell id -u) $(shell id -g) $(N)
endif

scratch/dot-local/lib/python3.4/site-packages/.xxx: scripts/install-python-deps.sh archives/$(GDAL-BLOB) scratch/local/gdal
	docker run -it --rm \
          -v $(shell pwd)/scratch/dot-local:/root/.local:rw \
          -v $(shell pwd)/scratch/local:/root/local:ro \
          -v $(shell pwd)/scratch/pip-cache:/root/.cache/pip:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(STAGE0) /scripts/install-python-deps.sh $(shell id -u) $(shell id -g)

archives/$(PYTHON-BLOB): scripts/build-python-blob.sh scratch/dot-local/lib/python3.4/site-packages/.xxx archives/geopyspark-$(GEOPYSPARK-SHA).zip
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scratch/dot-local:/root/.local:rw \
          -v $(shell pwd)/scratch/local:/root/local:ro \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(STAGE0) /scripts/build-python-blob.sh $(shell id -u) $(shell id -g) $(GEOPYSPARK-SHA) $(GEONOTEBOOK-SHA)

%: archives/%.zip
	rm -rf $@
	unzip -q $<

archives/$(GEOPYSPARK-WHEEL): geopyspark-$(GEOPYSPARK-SHA)
	make -C $(<) dist/$(GEOPYSPARK-WHEEL)
	cp -f $(<)/dist/$(GEOPYSPARK-WHEEL) $@

archives/$(GEOPYSPARK-JAR): geopyspark-$(GEOPYSPARK-SHA)
	make -C $< build
	cp -f $(<)/geopyspark/jars/$(GEOPYSPARK-JAR) $@

stage2: Dockerfile.stage2 blobs/geonotebook-$(GEONOTEBOOK-SHA).zip blobs/$(GEOPYSPARK-JAR) blobs/$(GEOPYSPARK-WHEEL) blobs/$(NETCDF-JAR) blobs/$(GDAL-BLOB) blobs/$(PYTHON-BLOB)
ifeq ($(TRAVIS),1)
	docker rmi $(STAGE0)
	rm -rf archives/ geopyspark-*/ netcdf-backend/ scratch/local/
endif
	docker build \
          --build-arg VERSION=$(GEOPYSPARK-VERSION) \
          --build-arg SHA=$(GEONOTEBOOK-SHA) \
          -t $(STAGE2) -f Dockerfile.stage2 .

clean:
	(cd netcdf-backend ; ./sbt "project gddp" clean ; cd ..)
	rm -f archives/$(GDAL-BLOB)
	rm -f archives/$(GEOPYSPARK-JAR)
	rm -f archives/$(GEOPYSPARK-WHEEL)
	rm -rf scratch/local/gdal/

cleaner: clean
	rm -f archives/$(NETCDF-JAR)
	rm -f blobs/*
	rm -rf geopyspark-*/
	rm -rf scratch/dot-local/*

cleanest: cleaner
	rm -rf archives/$(CDM-JAR)
	rm -rf scratch/local/src

mrproper: cleanest
	rm -rf archives/*
	rm -rf scratch/dot-local/*
	rm -rf scratch/pip-cache/*

publish: build
	docker tag $(STAGE2) $(IMG):latest
	docker push $(STAGE2)
	docker push $(IMG):latest

#################################

GEOPYSPARK-DIR ?= $(realpath ../../geopyspark/geopyspark)
GEONOTEBOOK-DIR ?= $(realpath ../../geonotebook/geonotebook)


run:
	mkdir -p $(HOME)/.aws
	docker run -it --rm --name geopyspark \
          -p 8000:8000 \
          $(EXTRA-FLAGS) \
          -v $(shell pwd)/notebooks:/home/hadoop/notebooks:rw \
          -v $(HOME)/.aws:/home/hadoop/.aws:ro \
          $(STAGE2)

run-editable:
	mkdir -p $(HOME)/.aws
	docker run -it --rm --name geopyspark \
          -p 8000:8000 \
          $(EXTRA-FLAGS) \
          -v $(GEOPYSPARK-DIR):/home/hadoop/.local/lib/python3.4/site-packages/geopyspark:rw \
          -v $(GEONOTEBOOK-DIR):/home/hadoop/.local/lib/python3.4/site-packages/geonotebook:rw \
          -v $(shell pwd)/notebooks:/home/hadoop/notebooks:rw \
          -v $(HOME)/.aws:/home/hadoop/.aws:ro \
          $(STAGE2)

shell:
	docker exec -it geopyspark bash
