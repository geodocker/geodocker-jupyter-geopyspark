#!/usr/bin/env bash

USERID=$1
GROUPID=$2

export LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64
yum remove -y gdal-devel
yum localinstall -y /archives/freetype2-2.8-33.x86_64.rpm /archives/boost162-1_62_0-33.x86_64.rpm /archives/gdal213-2.1.3-33.x86_64.rpm

cd /tmp
tar axvf /archives/mapbox-geometry-v0.9.2.tar.gz
tar axvf /archives/mapbox-variant-v1.1.3.tar.gz
cp -r geometry.hpp-0.9.2/include/mapbox /usr/local/include
cp -r variant-1.1.3/include/mapbox /usr/local/include
tar axvf /archives/rpmbuild.tar
cd rpmbuild
cp /archives/mapnik-093fcee6d1ba1fd360718ceade83894aeffc2548.zip SOURCES/
rpmbuild -v -bb --clean SPECS/mapnik.spec
cp -f RPMS/x86_64/*.rpm /archives/
chown -R $USERID:$GROUPID /archives/*
