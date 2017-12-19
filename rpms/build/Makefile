.PHONY: all gcc4 gcc6 rpms

FAMILY := quay.io/geodocker/emr-build
VERSION := 3
GCC4IMAGE := $(FAMILY):gcc4-$(VERSION)
GCC6IMAGE := $(FAMILY):gcc6-$(VERSION)
BASEIMAGE := quay.io/geodocker/jupyter-geopyspark:base-$(VERSION)
GDALIMAGE := quay.io/geodocker/jupyter-geopyspark:aws-build-gdal-$(VERSION)
GEOPYSPARK_SHA ?= a5ec919c53e1ae083b2d7284e9053e7173b6bfae
NETCDF_SHA ?= 69897d9f03df2efbf6f7d8317aa6ad004274b1eb
GEONOTEBOOK_SHA ?= 2c0073c60afc610f7d9616edbb3843e5ba8b68af
GEOPYSPARK_VERSION ?= 0.2.2


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
rpmbuild/RPMS/x86_64/s3fs-fuse-1.82-33.x86_64.rpm \
rpmbuild/RPMS/x86_64/freetype2-lib-2.8-33.x86_64.rpm rpmbuild/RPMS/x86_64/proj493-lib-4.9.3-33.x86_64.rpm rpmbuild/RPMS/x86_64/gdal213-2.1.3-33.x86_64.rpm \
rpmbuild/RPMS/x86_64/geopyspark-0.2.2-13.x86_64.rpm rpmbuild/RPMS/x86_64/geopyspark-worker-0.2.2-13.x86_64.rpm \
rpmbuild/RPMS/x86_64/boost162-lib-1_62_0-33.x86_64.rpm rpmbuild/RPMS/x86_64/mapnik-093fcee-33.x86_64.rpm rpmbuild/RPMS/x86_64/python-mapnik-e5f107d-33.x86_64.rpm \
rpmbuild/RPMS/x86_64/nodejs-8.5.0-13.x86_64.rpm rpmbuild/RPMS/x86_64/jupyterhub-0.7.2-13.x86_64.rpm rpmbuild/RPMS/x86_64/geonotebook-0.0.0-13.x86_64.rpm

blobs/spark-2.1.0-bin-hadoop2.7.tgz:
	curl -L "http://d3kbcqa49mib13.cloudfront.net/spark-2.1.0-bin-hadoop2.7.tgz" -o $@

include gcc.mk
include gdal.mk
include mapnik.mk
include geopyspark.mk
include jupyterhub.mk
include geonotebook.mk
include s3fs.mk
include gdal-and-friends.mk

clean:
	rm -f rpmbuild/SOURCES/*.tar rpmbuild/RPMS/x86_64/*-debuginfo-*.rpm

cleaner: clean
	rm -f archives/*.jar

cleanest: cleaner
	rm -f rpmbuild/RPMS/x86_64/*

mrproper: cleanest
	rm -f rpmbuild/SOURCES/SOURCES/*
