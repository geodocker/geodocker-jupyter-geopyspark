#!/usr/bin/env bash

USERID=$1
GROUPID=$2

export LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64
yum localinstall -y /archives/freetype2-2.8-33.x86_64.rpm /archives/boost162-1_62_0-33.x86_64.rpm /archives/mapnik-093fcee-33.x86_64.rpm

cd /tmp
tar axvf /archives/mapbox-geometry-v0.9.2.tar.gz
tar axvf /archives/mapbox-variant-v1.1.3.tar.gz
cp -r geometry.hpp-0.9.2/include/mapbox /usr/local/include
cp -r variant-1.1.3/include/mapbox /usr/local/include
tar axvf /archives/rpmbuild.tar
cd rpmbuild
cp /archives/python-mapnik-e5f107d8d459590829d50c976c7a4222d8f4737c.zip SOURCES/
rpmbuild -v -bb --clean SPECS/python-mapnik.spec
cp -f RPMS/x86_64/*.rpm /archives/
chown -R $USERID:$GROUPID /archives/*
