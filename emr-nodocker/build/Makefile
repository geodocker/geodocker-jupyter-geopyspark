.PHONY: all gcc4 gcc6 jars rpms

FAMILY := quay.io/geodocker/emr-build
VERSION := 0
GCC4IMAGE := $(FAMILY):gcc4-$(VERSION)
GCC6IMAGE := $(FAMILY):gcc6-$(VERSION)
GEOPYSPARK_SHA ?= 686ad28724d7648bec5e7e1a39cd48d5d80fca79
NETCDF_SHA ?= 8e059120f4f7b49c38a326633e31d8120906ef4a
GEONOTEBOOK_SHA ?= 2c0073c60afc610f7d9616edbb3843e5ba8b68af
GEOPYSPARK_VERSION ?= 0.2.2


all:
	echo "see build.sh"

gcc4:
	docker build -t "$(FAMILY):$@-$(VERSION)" -f Dockerfile.$@ .

gcc6: rpmbuild/RPMS/x86_64/gcc6-6.4.0-33.x86_64.rpm
	docker build -t "$(FAMILY):$@-$(VERSION)" -f Dockerfile.$@ .

jars: archives/$(CDM_JAR) archives/$(GEOPYSPARK_JAR) archives/$(NETCDF_JAR)

rpms: rpmbuild/RPMS/x86_64/gcc6-lib-6.4.0-33.x86_64.rpm \
rpmbuild/RPMS/x86_64/freetype2-lib-2.8-33.x86_64.rpm rpmbuild/RPMS/x86_64/proj493-lib-4.9.3-33.x86_64.rpm rpmbuild/RPMS/x86_64/gdal213-lib-2.1.3-33.x86_64.rpm \
rpmbuild/RPMS/x86_64/geopyspark-0.2.2-13.x86_64.rpm rpmbuild/RPMS/x86_64/geopyspark-worker-0.2.2-13.x86_64.rpm \
rpmbuild/RPMS/x86_64/boost162-lib-1_62_0-33.x86_64.rpm rpmbuild/RPMS/x86_64/mapnik-093fcee-33.x86_64.rpm rpmbuild/RPMS/x86_64/python-mapnik-e5f107d-33.x86_64.rpm \
rpmbuild/RPMS/x86_64/nodejs-8.5.0-13.x86_64.rpm rpmbuild/RPMS/x86_64/jupyterhub-0.7.2-13.x86_64.rpm rpmbuild/RPMS/x86_64/geonotebook-0.0.0-13.x86_64.rpm

include gcc.mk
include gdal.mk
include mapnik.mk
include geopyspark.mk
include jupyterhub.mk
include geonotebook.mk

clean:
	rm -f rpmbuild/RPMS/x86_64/* archives/*debug*.rpm

cleaner: clean
	rm -f archives/*.tar

cleanest: cleaner
	rm -f archives/*.rpm archives/*.jar

mrproper: cleanest
	rm -f archives/*.tar.gz archives/*.tar.bz2 archives/*.tar.xz archives/*.zip
