.PHONY: all gcc4 aws-build-gdal rpms src wheels

FAMILY := quay.io/geodocker/emr-build
VERSION := 8
GCC4IMAGE := $(FAMILY):gcc4-$(VERSION)
BASEIMAGE := quay.io/geodocker/jupyter-geopyspark:base-$(VERSION)
INTERFACE ?= eth0
IP_ADDR := $(shell ifconfig $(INTERFACE) | grep -i mask | awk '{print $$2}' | cut -f2 -d:)

all:
	echo "see build.sh"

gcc4:
	docker build -t $(GCC4IMAGE) -f Dockerfile.$@ .

base: blobs/spark-2.1.0-bin-hadoop2.7.tgz rpms wheel/http-requirements.txt
	docker run -dit --rm --name rpm-server --hostname rpm-server -p "18080:80" -v $(shell pwd)/rpmbuild/RPMS/x86_64:/usr/local/apache2/htdocs httpd:2.4
	docker run -dit --rm --name whl-server --hostname whl-server -p "28080:80" -v $(shell pwd)/wheel:/usr/local/apache2/htdocs httpd:2.4
	docker build --no-cache --add-host="localhost:$(IP_ADDR)" -t $(BASEIMAGE) -f Dockerfile.base .
	docker stop whl-server
	docker stop rpm-server

rpms: rpmbuild/RPMS/x86_64/proj493-lib-4.9.3-33.x86_64.rpm \
rpmbuild/RPMS/x86_64/hdf5-1.8.20-33.x86_64.rpm \
rpmbuild/RPMS/x86_64/netcdf-4.5.0-33.x86_64.rpm \
rpmbuild/RPMS/x86_64/gdal231-2.3.1-33.x86_64.rpm \
rpmbuild/RPMS/x86_64/nodejs-8.5.0-13.x86_64.rpm \
rpmbuild/RPMS/x86_64/configurable-http-proxy-0.0.0-13.x86_64.rpm

src: rpmbuild/SOURCES/curl-7.57.0.tar.bz2 rpmbuild/SOURCES/zlib-1.2.11.tar.gz \
rpmbuild/SOURCES/libpng-1.6.30.tar.xz rpmbuild/SOURCES/geos-3.6.1.tar.bz2 \
rpmbuild/SOURCES/lcms2-2.8.tar.gz rpmbuild/SOURCES/openjpeg-2.3.0.tar.gz \
rpmbuild/SOURCES/hdf5-1.8.20.tar.bz2 rpmbuild/SOURCES/netcdf-4.5.0.tar.gz \
rpmbuild/SOURCES/gdal-2.3.1.tar.gz rpmbuild/SOURCES/node-v8.5.0.tar.gz \
rpmbuild/SOURCES/proj-4.9.3.tar.gz

blobs/spark-2.1.0-bin-hadoop2.7.tgz:
	curl -L "http://d3kbcqa49mib13.cloudfront.net/spark-2.1.0-bin-hadoop2.7.tgz" -o $@

rpmbuild/SOURCES/%.tar: %/
	tar cvf $@ $<

include configurable-http-proxy.mk
include gdal.mk
include wheels.mk

clean:
	rm -f rpmbuild/SOURCES/*.tar

cleaner: clean

cleanest: cleaner
	rm -f rpmbuild/RPMS/x86_64/*

mrproper: cleanest
	rm -f rpmbuild/SOURCES/SOURCES/*
	rm -f wheel/*.whl
