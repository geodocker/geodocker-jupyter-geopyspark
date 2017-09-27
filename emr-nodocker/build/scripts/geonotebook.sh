#!/usr/bin/env bash

USERID=$1
GROUPID=$2
GEOPYSPARK_RPM=$3

yum install -y \
    /archives/$GEOPYSPARK_RPM \
    /archives/nodejs-8.5.0-13.x86_64.rpm /archives/jupyterhub-0.7.2-13.x86_64.rpm \
    /archives/freetype2-2.8-33.x86_64.rpm /archives/proj493-4.9.3-33.x86_64.rpm /archives/gdal213-2.1.3-33.x86_64.rpm \
    /archives/boost162-lib-1_62_0-33.x86_64.rpm /archives/mapnik-093fcee-33.x86_64.rpm /archives/python-mapnik-e5f107d-33.x86_64.rpm
ldconfig

cd /tmp
tar axvf /archives/rpmbuild.tar
cd rpmbuild
cp /archives/geonotebook.tar SOURCES/
rpmbuild -v -bb --clean SPECS/geonotebook.spec
cp -f RPMS/x86_64/*.rpm /archives/
chown -R $USERID:$GROUPID /archives/*
