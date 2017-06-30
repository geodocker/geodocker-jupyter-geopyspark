.PHONY: stage0 stage1 all

N ?= 33
VERSION := 10
STAGE0 := jamesmcclain/jupyter-geopyspark:stage0
STAGE1 := quay.io/geodocker/jupyter-geopyspark:$(VERSION)
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


all: stage0 stage1

archives/zlib-1.2.11.tar.gz:
	curl -L "https://downloads.sourceforge.net/project/libpng/zlib/1.2.11/zlib-1.2.11.tar.gz?r=http%3A%2F%2Fwww.zlib.net%2F&ts=1490316463&use_mirror=pilotfiber" -o archives/zlib-1.2.11.tar.gz

archives/libpng-1.6.28.tar.gz:
	curl -L "https://downloads.sourceforge.net/project/libpng/libpng16/1.6.28/libpng-1.6.28.tar.gz?r=http%3A%2F%2Fwww.libpng.org%2Fpub%2Fpng%2Flibpng.html&ts=1490316660&use_mirror=superb-sea2" -o archives/libpng-1.6.28.tar.gz

archives/geos-3.6.1.tar.bz2:
	curl -L "http://download.osgeo.org/geos/geos-3.6.1.tar.bz2" -o archives/geos-3.6.1.tar.bz2

archives/proj-4.9.3.tar.gz:
	curl -L "http://download.osgeo.org/proj/proj-4.9.3.tar.gz" -o archives/proj-4.9.3.tar.gz

archives/lcms2-2.8.tar.gz:
	curl -L "https://downloads.sourceforge.net/project/lcms/lcms/2.8/lcms2-2.8.tar.gz?r=&ts=1490316968&use_mirror=pilotfiber" -o archives/lcms2-2.8.tar.gz

archives/openjpeg-v2.1.2.tar.gz:
	curl -L "https://github.com/uclouvain/openjpeg/archive/v2.1.2.tar.gz" -o archives/openjpeg-v2.1.2.tar.gz

archives/gdal-2.1.3.tar.gz:
	curl -L "http://download.osgeo.org/gdal/2.1.3/gdal-2.1.3.tar.gz" -o archives/gdal-2.1.3.tar.gz

archives/geopyspark-$(GEOPYSPARK-SHA).zip:
	curl -L "https://github.com/locationtech-labs/geopyspark/archive/$(GEOPYSPARK-SHA).zip" -o archives/geopyspark-$(GEOPYSPARK-SHA).zip

archives/geonotebook-$(GEONOTEBOOK-SHA).zip:
	curl -L "https://github.com/geotrellis/geonotebook/archive/$(GEONOTEBOOK-SHA).zip" -o archives/geonotebook-$(GEONOTEBOOK-SHA).zip

archives/s3+hdfs.zip:
	curl -L "https://github.com/Unidata/thredds/archive/feature/s3+hdfs.zip" -o $@

archives/$(CDM-JAR): scripts/netcdf.sh archives/s3+hdfs.zip
	docker run -it --rm \
	   -v $(shell pwd)/archives:/archives:rw \
	   -v $(shell pwd)/thredds-feature-s3-hdfs:/thredds:rw \
	   -v $(shell pwd)/scripts:/scripts:ro \
           -v $(HOME)/.m2:/root/.m2:rw \
           -v $(HOME)/.gradle:/root/.gradle:rw \
           openjdk:8-jdk /scripts/netcdf.sh $(shell id -u) $(shell id -g) $(CDM-JAR)

archives/$(NETCDF-JAR): archives/$(CDM-JAR) archives/$(GEOPYSPARK-JAR) $(call rwildcard, netcdf-backend/, *.scala)
	cp -f archives/$(CDM-JAR) archives/$(GEOPYSPARK-JAR) /tmp
	(cd netcdf-backend; ./sbt "project gddp" assembly; cd ..)
	cp -f netcdf-backend/gddp/target/scala-2.11/$(NETCDF-JAR) $@
	rm -f /tmp/$(CDM-JAR) /tmp/$(GEOPYSPARK-JAR)

blobs/%: archives/%
	cp -f $< $@

stage0: Dockerfile.stage0
	(docker images | grep 'jamesmcclain/jupyter-geopyspark \+stage0') || (docker pull $(STAGE0)) || (build -t $(STAGE0) -f Dockerfile.stage0 .)

archives/$(GDAL-BLOB): $(SRC) scripts/build-native-blob.sh
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scratch/local:/root/local:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(STAGE0) /scripts/build-native-blobs.sh $(shell id -u) $(shell id -g) $(N)

scratch/dot-local/lib/python3.4/site-packages: scripts/install-python-deps.sh archives/$(GDAL-BLOB)
	docker run -it --rm \
          -v $(shell pwd)/scratch/dot-local:/root/.local:rw \
          -v $(shell pwd)/scratch/local:/root/local:ro \
          -v $(shell pwd)/scratch/pip-cache:/root/.cache/pip:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(STAGE0) /scripts/install-python-deps.sh $(shell id -u) $(shell id -g)

archives/$(PYTHON-BLOB): scripts/build-python-blob.sh scratch/dot-local/lib/python3.4/site-packages
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scratch/dot-local:/root/.local:rw \
          -v $(shell pwd)/scratch/local:/root/local:ro \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(STAGE0) /scripts/build-python-blob.sh $(shell id -u) $(shell id -g) $(GEOPYSPARK-SHA) $(GEONOTEBOOK-SHA)

%: archives/%.zip
	rm -rf $@
	unzip $<

archives/$(GEOPYSPARK-WHEEL): geopyspark-$(GEOPYSPARK-SHA)
	make -C $(<) dist/$(GEOPYSPARK-WHEEL)
	cp -f $(<)/dist/$(GEOPYSPARK-WHEEL) $@

archives/$(GEOPYSPARK-JAR): geopyspark-$(GEOPYSPARK-SHA)
	make -C $< build
	cp -f $(<)/geopyspark/jars/$(GEOPYSPARK-JAR) $@

stage1: Dockerfile.stage1 blobs/geonotebook-$(GEONOTEBOOK-SHA).zip blobs/$(GEOPYSPARK-JAR) blobs/$(GEOPYSPARK-WHEEL) blobs/$(NETCDF-JAR) blobs/$(GDAL-BLOB) blobs/$(PYTHON-BLOB)
	docker build -t $(STAGE1) -f Dockerfile.stage1 .

# run:
# 	docker run -it \
# 	  --rm \
# 	  --name geopyspark \
# 	  -p 8000:8000 \
# 	  -p 8888:8888 \
# 	  -p 8033:8033 \
#           -p 4040:4040 \
#           -p 4041:4041 \
#           -p 4042:4042 \
#           -p 4043:4043 \
#           -p 4044:4044 \
# 	  -v /tmp/L57.Globe.month09.2010.hh09vv04.h6v1.doy247to273.NBAR.v3.0.tiff:/tmp/L57.Globe.month09.2010.hh09vv04.h6v1.doy247to273.NBAR.v3.0.tiff \
# 	  -v $(shell pwd)/notebooks:/home/hadoop/notebooks:rw \
# 	  -v $(HOME)/.aws:/home/hadoop/.aws:ro \
# 	  $(STAGE1)

# run-editable:
# 	docker run -it \
# 	  --rm \
# 	  --name geopyspark \
# 	  -p 8000:8000 \
# 	  -p 8888:8888 \
# 	  -p 8033:8033 \
#           -p 4040:4040 \
#           -p 4041:4041 \
#           -p 4042:4042 \
#           -p 4043:4043 \
#           -p 4044:4044 \
#       -v $(realpath ../geopyspark):/home/hadoop/.local/lib/python3.4/site-packages/geopyspark \
# 	  -v /tmp/L57.Globe.month09.2010.hh09vv04.h6v1.doy247to273.NBAR.v3.0.tiff:/tmp/L57.Globe.month09.2010.hh09vv04.h6v1.doy247to273.NBAR.v3.0.tiff \
# 	  -v $(shell pwd)/notebooks:/home/hadoop/notebooks:rw \
# 	  -v $(HOME)/.aws:/home/hadoop/.aws:ro \
# 	  $(STAGE1)

shell:
	docker exec -it geopyspark bash

clean:
	rm -f archives/$(GDAL-BLOB)
	rm -f archives/$(GEOPYSPARK-WHEEL)
	rm -f archives/$(GEOPYSPARK-JAR)
	(cd netcdf-backend ; ./sbt "project gddp" clean ; cd ..)

cleaner: clean
	rm -rf scratch/local/gdal
	rm -f blobs/*
	rm -f archives/$(NETCDF-JAR) archives/$(CDM-JAR)

cleanest: cleaner
	rm -rf scratch/local/src
