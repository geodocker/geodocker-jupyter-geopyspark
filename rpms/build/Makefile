.PHONY: all gcc4 gcc6 aws-build-gdal rpms src wheels

FAMILY := quay.io/geodocker/emr-build
VERSION := 6
GCC4IMAGE := $(FAMILY):gcc4-$(VERSION)
GCC6IMAGE := $(FAMILY):gcc6-$(VERSION)
BASEIMAGE := quay.io/geodocker/jupyter-geopyspark:base-$(VERSION)
INTERFACE ?= eth0


all:
	echo "see build.sh"

gcc4:
	docker build -t $(GCC4IMAGE) -f Dockerfile.$@ .

gcc6: rpmbuild/RPMS/x86_64/gcc6-6.4.0-33.x86_64.rpm
	docker build -t $(GCC6IMAGE) -f Dockerfile.$@ .

base: blobs/spark-2.1.0-bin-hadoop2.7.tgz rpms wheel/ipykernel-4.7.0.dev0-py3-none-any.whl
	docker run -dit --rm --name rpm-server --hostname rpm-server -p "18080:80" -v $(shell pwd)/rpmbuild/RPMS/x86_64:/usr/local/apache2/htdocs httpd:2.4
	docker run -dit --rm --name whl-server --hostname whl-server -p "28080:80" -v $(shell pwd)/wheel:/usr/local/apache2/htdocs httpd:2.4
	docker build --no-cache --add-host="localhost:$(shell ifconfig $(INTERFACE) | grep 'inet addr:' | sed 's,.*inet addr:\([^ ]*\).*,\1,')" -t $(BASEIMAGE) -f Dockerfile.base .
	docker stop whl-server
	docker stop rpm-server

rpms: rpmbuild/RPMS/x86_64/gcc6-lib-6.4.0-33.x86_64.rpm \
rpmbuild/RPMS/x86_64/freetype2-lib-2.8-33.x86_64.rpm \
rpmbuild/RPMS/x86_64/proj493-lib-4.9.3-33.x86_64.rpm \
rpmbuild/RPMS/x86_64/hdf5-1.8.20-33.x86_64.rpm \
rpmbuild/RPMS/x86_64/netcdf-4.5.0-33.x86_64.rpm \
rpmbuild/RPMS/x86_64/gdal213-2.1.3-33.x86_64.rpm \
rpmbuild/RPMS/x86_64/boost162-lib-1_62_0-33.x86_64.rpm \
rpmbuild/RPMS/x86_64/mapnik-093fcee-33.x86_64.rpm \
rpmbuild/RPMS/x86_64/nodejs-8.5.0-13.x86_64.rpm \
rpmbuild/RPMS/x86_64/configurable-http-proxy-0.0.0-13.x86_64.rpm

src: rpmbuild/SOURCES/isl-0.16.1.tar.bz2 rpmbuild/SOURCES/gcc-6.4.0.tar.xz \
rpmbuild/SOURCES/curl-7.57.0.tar.bz2 rpmbuild/SOURCES/zlib-1.2.11.tar.gz \
rpmbuild/SOURCES/libpng-1.6.30.tar.xz rpmbuild/SOURCES/geos-3.6.1.tar.bz2 \
rpmbuild/SOURCES/lcms2-2.8.tar.gz rpmbuild/SOURCES/openjpeg-v2.1.2.tar.gz \
rpmbuild/SOURCES/proj-4.9.3.tar.gz rpmbuild/SOURCES/freetype-2.8.tar.gz \
rpmbuild/SOURCES/hdf5-1.8.20.tar.bz2 rpmbuild/SOURCES/netcdf-4.5.0.tar.gz \
rpmbuild/SOURCES/gdal-2.1.3.tar.gz rpmbuild/SOURCES/node-v8.5.0.tar.gz \
rpmbuild/SOURCES/boost_1_62_0.tar.bz2 \
rpmbuild/SOURCES/mapbox-variant-v1.1.3.tar.gz \
rpmbuild/SOURCES/mapbox-geometry-v0.9.2.tar.gz \
rpmbuild/SOURCES/mapnik-093fcee6d1ba1fd360718ceade83894aeffc2548.zip

blobs/spark-2.1.0-bin-hadoop2.7.tgz:
	curl -L "http://d3kbcqa49mib13.cloudfront.net/spark-2.1.0-bin-hadoop2.7.tgz" -o $@

rpmbuild/SOURCES/%.tar: %/
	tar cvf $@ $<

include configurable-http-proxy.mk
include gcc.mk
include gdal.mk
include mapnik.mk
include wheels.mk

clean:
	rm -f rpmbuild/SOURCES/*.tar

cleaner: clean

cleanest: cleaner
	rm -f rpmbuild/RPMS/x86_64/*

mrproper: cleanest
	rm -f rpmbuild/SOURCES/SOURCES/*
