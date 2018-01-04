.PHONY: all gcc4 gcc6 aws-build-gdal rpms

FAMILY := quay.io/geodocker/emr-build
VERSION := 3
GCC4IMAGE := $(FAMILY):gcc4-$(VERSION)
GCC6IMAGE := $(FAMILY):gcc6-$(VERSION)
BASEIMAGE := quay.io/geodocker/jupyter-geopyspark:base-$(VERSION)
GDALIMAGE := quay.io/geodocker/jupyter-geopyspark:aws-build-gdal-$(VERSION)
GEOPYSPARK_SHA ?= cd0065baf04a8acc8c4763397968329afccb7b01
GEOPYSPARK_NETCDF_SHA ?= 388ac89f170916c716723b7f40fd0a4118eb238a
GEONOTEBOOK_SHA ?= 2c0073c60afc610f7d9616edbb3843e5ba8b68af
GEOPYSPARK_VERSION ?= 0.3.0


all:
	echo "see build.sh"

gcc4:
	docker build -t $(GCC4IMAGE) -f Dockerfile.$@ .

gcc6: rpmbuild/RPMS/x86_64/gcc6-6.4.0-33.x86_64.rpm
	docker build -t $(GCC6IMAGE) -f Dockerfile.$@ .

aws-build-gdal: blobs/gdal-and-friends.tar.gz
	docker build -t $(GDALIMAGE) -f Dockerfile.aws-build-gdal .

base: blobs/gdal-and-friends.tar.gz blobs/spark-2.1.0-bin-hadoop2.7.tgz rpms
	docker build -t $(BASEIMAGE) -f Dockerfile.base .

rpms: rpmbuild/RPMS/x86_64/gcc6-lib-6.4.0-33.x86_64.rpm \
rpmbuild/RPMS/x86_64/freetype2-lib-2.8-33.x86_64.rpm rpmbuild/RPMS/x86_64/proj493-lib-4.9.3-33.x86_64.rpm rpmbuild/RPMS/x86_64/gdal213-2.1.3-33.x86_64.rpm \
rpmbuild/RPMS/x86_64/geopyspark-$(GEOPYSPARK_VERSION)-13.x86_64.rpm rpmbuild/RPMS/x86_64/geopyspark-worker-$(GEOPYSPARK_VERSION)-13.x86_64.rpm \
rpmbuild/RPMS/x86_64/boost162-lib-1_62_0-33.x86_64.rpm rpmbuild/RPMS/x86_64/mapnik-093fcee-33.x86_64.rpm rpmbuild/RPMS/x86_64/python-mapnik-e5f107d-33.x86_64.rpm \
rpmbuild/RPMS/x86_64/nodejs-8.5.0-13.x86_64.rpm rpmbuild/RPMS/x86_64/jupyterhub-0.7.2-13.x86_64.rpm rpmbuild/RPMS/x86_64/geonotebook-0.0.0-13.x86_64.rpm

src: rpmbuild/SOURCES/isl-0.16.1.tar.bz2 rpmbuild/SOURCES/gcc-6.4.0.tar.xz rpmbuild/SOURCES/curl-7.57.0.tar.bz2 \
rpmbuild/SOURCES/zlib-1.2.11.tar.gz rpmbuild/SOURCES/libpng-1.6.30.tar.xz rpmbuild/SOURCES/geos-3.6.1.tar.bz2 \
rpmbuild/SOURCES/lcms2-2.8.tar.gz rpmbuild/SOURCES/openjpeg-v2.1.2.tar.gz rpmbuild/SOURCES/proj-4.9.3.tar.gz \
rpmbuild/SOURCES/freetype-2.8.tar.gz rpmbuild/SOURCES/gdal-2.1.3.tar.gz rpmbuild/SOURCES/node-v8.5.0.tar.gz \
rpmbuild/SOURCES/boost_1_62_0.tar.bz2 rpmbuild/SOURCES/mapbox-variant-v1.1.3.tar.gz rpmbuild/SOURCES/mapbox-geometry-v0.9.2.tar.gz \
rpmbuild/SOURCES/mapnik-093fcee6d1ba1fd360718ceade83894aeffc2548.zip rpmbuild/SOURCES/python-mapnik-e5f107d8d459590829d50c976c7a4222d8f4737c.zip \
geopyspark-deps jupyterhub-deps geonotebook-deps

blobs/spark-2.1.0-bin-hadoop2.7.tgz:
	curl -L "http://d3kbcqa49mib13.cloudfront.net/spark-2.1.0-bin-hadoop2.7.tgz" -o $@

include gcc.mk
include gdal.mk
include mapnik.mk
include geopyspark.mk
include jupyterhub.mk
include geonotebook.mk
include gdal-and-friends.mk

clean:
	rm -f rpmbuild/SOURCES/*.tar rpmbuild/RPMS/x86_64/*-debuginfo-*.rpm

cleaner: clean
	rm -f archives/*.jar

cleanest: cleaner
	rm -f rpmbuild/RPMS/x86_64/*

mrproper: cleanest
	rm -f rpmbuild/SOURCES/SOURCES/*
