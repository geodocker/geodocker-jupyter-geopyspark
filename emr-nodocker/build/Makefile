.PHONY: all gcc4 gcc6 jars

FAMILY := quay.io/geodocker/emr-build
VERSION := 0
GCC4IMAGE := $(FAMILY):gcc4-$(VERSION)
GCC6IMAGE := $(FAMILY):gcc6-$(VERSION)
GEOPYSPARK_SHA ?= 686ad28724d7648bec5e7e1a39cd48d5d80fca79
NETCDF_SHA ?= 8e059120f4f7b49c38a326633e31d8120906ef4a
GEONOTEBOOK_SHA ?= 2c0073c60afc610f7d9616edbb3843e5ba8b68af
GEOPYSPARK_VERSION ?= 0.2.2
GEOPYSPARK_JAR := geotrellis-backend-assembly-$(GEOPYSPARK_VERSION).jar
NETCDF_JAR := gddp-assembly-$(GEOPYSPARK_VERSION).jar
CDM_JAR := netcdfAll-5.0.0-SNAPSHOT.jar


all: blobs/gdal-and-friends.tar.gz \
   blobs/gcc6-lib-6.4.0-33.x86_64.rpm \
   blobs/proj493-lib-4.9.3-33.x86_64.rpm \
   blobs/freetype2-lib-2.8-33.x86_64.rpm \
   blobs/boost162-lib-1_62_0-33.x86_64.rpm \
   blobs/gdal213-lib-2.1.3-33.x86_64.rpm \
   blobs/mapnik-093fcee-33.x86_64.rpm \
   blobs/python-mapnik-e5f107d-33.x86_64.rpm

blobs/%: archives/%
	cp -f $< $@

gcc4:
	docker build -t "$(FAMILY):$@-$(VERSION)" -f Dockerfile.$@ .

gcc6: blobs/gcc6-6.4.0-33.x86_64.rpm
	docker build -t "$(FAMILY):$@-$(VERSION)" -f Dockerfile.$@ .

########################################################################

archives/s3+hdfs.zip:
	curl -L "https://github.com/Unidata/thredds/archive/feature/s3+hdfs.zip" -o $@

archives/geopyspark-$(GEOPYSPARK_SHA).zip:
	curl -L "https://github.com/locationtech-labs/geopyspark/archive/$(GEOPYSPARK_SHA).zip" -o $@

archives/geonotebook-$(GEONOTEBOOK_SHA).zip:
	curl -L "https://github.com/geotrellis/geonotebook/archive/$(GEONOTEBOOK_SHA).zip" -o $@

archives/geopyspark-netcdf-$(NETCDF_SHA).zip:
	curl -L "https://github.com/geotrellis/geopyspark-netcdf/archive/$(NETCDF_SHA).zip" -o $@

jars: archives/$(CDM_JAR) archives/$(GEOPYSPARK_JAR) archives/$(NETCDF_JAR)

archives/$(CDM_JAR): scripts/netcdf-jar.sh archives/s3+hdfs.zip
	docker run -it --rm \
           -v $(shell pwd)/archives:/archives:rw \
           -v $(shell pwd)/scripts:/scripts:ro \
           -v $(HOME)/.m2:/root/.m2:rw \
           -v $(HOME)/.gradle:/root/.gradle:rw \
           openjdk:8-jdk /scripts/netcdf-jar.sh $(shell id -u) $(shell id -g) $(CDM_JAR)

archives/$(GEOPYSPARK_JAR) archives/$(NETCDF_JAR): scripts/geopyspark-jar.sh archives/geopyspark-$(GEOPYSPARK_SHA).zip archives/geopyspark-netcdf-$(NETCDF_SHA).zip archives/$(CDM_JAR)
	docker run -it --rm \
           -v $(shell pwd)/archives:/archives:rw \
           -v $(shell pwd)/scripts:/scripts:ro \
           -v $(HOME)/.m2:/root/.m2:rw \
           -v $(HOME)/.ivy2:/root/.ivy2:rw \
           openjdk:8-jdk /scripts/geopyspark-jar.sh $(shell id -u) $(shell id -g) \
	   $(GEOPYSPARK_SHA) $(GEOPYSPARK_JAR) $(NETCDF_SHA) $(NETCDF_JAR)

########################################################################

archives/isl-0.16.1.tar.bz2:
	curl -L "ftp://gcc.gnu.org/pub/gcc/infrastructure/isl-0.16.1.tar.bz2" -o $@

archives/gcc-6.4.0.tar.xz:
	curl -L "http://mirrors.concertpass.com/gcc/releases/gcc-6.4.0/gcc-6.4.0.tar.xz" -o $@

archives/proj-4.9.3.tar.gz:
	curl -L "http://download.osgeo.org/proj/proj-4.9.3.tar.gz" -o $@

archives/gdal-2.1.3.tar.gz:
	curl -L "http://download.osgeo.org/gdal/2.1.3/gdal-2.1.3.tar.gz" -o $@

archives/node-v8.5.0.tar.gz:
	curl -L "https://nodejs.org/dist/v8.5.0/node-v8.5.0.tar.gz" -o $@

archives/boost_1_62_0.tar.bz2:
	curl -L "https://sourceforge.net/projects/boost/files/boost/1.62.0/boost_1_62_0.tar.bz2" -o $@

archives/freetype-2.8.tar.gz:
	curl -L "https://download.savannah.gnu.org/releases/freetype/freetype-2.8.tar.gz" -o $@

archives/mapbox-variant-v1.1.3.tar.gz:
	curl -L "https://github.com/mapbox/variant/archive/v1.1.3.tar.gz" -o $@

archives/mapbox-geometry-v0.9.2.tar.gz:
	curl -L "https://github.com/mapbox/geometry.hpp/archive/v0.9.2.tar.gz" -o $@

archives/mapnik-093fcee6d1ba1fd360718ceade83894aeffc2548.zip:
	curl -L "https://github.com/mapnik/mapnik/archive/093fcee6d1ba1fd360718ceade83894aeffc2548.zip" -o $@

archives/python-mapnik-e5f107d8d459590829d50c976c7a4222d8f4737c.zip:
	curl -L "https://github.com/mapnik/python-mapnik/archive/e5f107d8d459590829d50c976c7a4222d8f4737c.zip" -o $@

archives/ipykernel-629ac54cae9767310616d47d769665453619ac64.zip:
	curl -L "https://github.com/ipython/ipykernel/archive/629ac54cae9767310616d47d769665453619ac64.zip" -o $@

########################################################################

archives/%.tar: %/
	tar cvf $@ $<

archives/gcc6-6.4.0-33.x86_64.rpm archives/gcc6-lib-6.4.0-33.x86_64.rpm: rpmbuild/SPECS/gcc6.spec $(shell scripts/not.sh archives/rpmbuild.tar) $(shell scripts/not.sh archives/gcc-6.4.0.tar.xz) $(shell scripts/not.sh archives/isl-0.16.1.tar.bz2)
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(GCC4IMAGE) /scripts/gcc6.sh $(shell id -u) $(shell id -g)

archives/nodejs-8.5.0-13.x86_64.rpm: rpmbuild/SPECS/nodejs.spec $(shell scripts/not.sh archives/rpmbuild.tar) archives/node-v8.5.0.tar.gz
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(GCC6IMAGE) /scripts/nodejs.sh $(shell id -u) $(shell id -g)

archives/boost162-1_62_0-33.x86_64.rpm archives/boost162-lib-1_62_0-33.x86_64.rpm: rpmbuild/SPECS/boost162.spec $(shell scripts/not.sh archives/rpmbuild.tar) archives/boost_1_62_0.tar.bz2
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(GCC6IMAGE) /scripts/boost162.sh $(shell id -u) $(shell id -g)

archives/freetype2-2.8-33.x86_64.rpm archives/freetype2-lib-2.8-33.x86_64.rpm: rpmbuild/SPECS/freetype.spec $(shell scripts/not.sh archives/rpmbuild.tar) archives/freetype-2.8.tar.gz
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(GCC6IMAGE) /scripts/freetype.sh $(shell id -u) $(shell id -g)

archives/proj493-4.9.3-33.x86_64.rpm archives/proj493-lib-4.9.3-33.x86_64.rpm: rpmbuild/SPECS/proj.spec $(shell scripts/not.sh archives/rpmbuild.tar) archives/proj-4.9.3.tar.gz
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(GCC6IMAGE) /scripts/proj.sh $(shell id -u) $(shell id -g)

archives/gdal213-2.1.3-33.x86_64.rpm archives/gdal213-lib-2.1.3-33.x86_64.rpm: rpmbuild/SPECS/gdal.spec $(shell scripts/not.sh archives/rpmbuild.tar) archives/proj493-4.9.3-33.x86_64.rpm archives/gdal-2.1.3.tar.gz
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(GCC6IMAGE) /scripts/gdal.sh $(shell id -u) $(shell id -g)

archives/mapnik-093fcee-33.x86_64.rpm: rpmbuild/SPECS/mapnik.spec $(shell scripts/not.sh archives/rpmbuild.tar) archives/proj493-4.9.3-33.x86_64.rpm archives/freetype2-2.8-33.x86_64.rpm archives/boost162-1_62_0-33.x86_64.rpm archives/gdal213-2.1.3-33.x86_64.rpm archives/mapbox-geometry-v0.9.2.tar.gz archives/mapbox-variant-v1.1.3.tar.gz archives/mapnik-093fcee6d1ba1fd360718ceade83894aeffc2548.zip
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(GCC6IMAGE) /scripts/mapnik.sh $(shell id -u) $(shell id -g)

archives/python-mapnik-e5f107d-33.x86_64.rpm: rpmbuild/SPECS/python-mapnik.spec $(shell scripts/not.sh archives/rpmbuild.tar) archives/proj493-4.9.3-33.x86_64.rpm archives/freetype2-2.8-33.x86_64.rpm archives/boost162-lib-1_62_0-33.x86_64.rpm archives/gdal213-2.1.3-33.x86_64.rpm archives/mapnik-093fcee-33.x86_64.rpm archives/mapbox-geometry-v0.9.2.tar.gz archives/mapbox-variant-v1.1.3.tar.gz archives/python-mapnik-e5f107d8d459590829d50c976c7a4222d8f4737c.zip
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(GCC6IMAGE) /scripts/python-mapnik.sh $(shell id -u) $(shell id -g)

archives/jupyterhub-0.7.2-13.x86_64.rpm: rpmbuild/SPECS/jupyterhub.spec $(shell scripts/not.sh archives/rpmbuild.tar) archives/jupyterhub.tar archives/ipykernel-629ac54cae9767310616d47d769665453619ac64.zip archives/nodejs-8.5.0-13.x86_64.rpm
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(GCC6IMAGE) /scripts/jupyterhub.sh $(shell id -u) $(shell id -g)

########################################################################

archives/gdal-and-friends.tar.gz: $(shell scripts/not.sh scripts/build-gdal.sh) \
   archives/gdal-2.1.3.tar.gz \
   archives/geos-3.6.1.tar.bz2 \
   archives/lcms2-2.8.tar.gz \
   archives/libpng-1.6.30.tar.xz \
   archives/proj-4.9.3.tar.gz \
   archives/openjpeg-v2.1.2.tar.gz \
   archives/zlib-1.2.11.tar.gz
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(FAMILY):aws-build-base /scripts/build-gdal.sh $(shell id -u) $(shell id -g)

########################################################################

clean:
	rm -f blobs/* archives/*debug*.rpm

cleaner: clean
	rm -f archives/rpmbuild.tar

cleanest: cleaner
	rm -f archives/*.rpm archives/*.jar

mrproper: cleanest
	rm -f archives/*.tar.gz archives/*.tar.bz2 archives/*.tar.xz archives/*.zip
