#!/usr/bin/env bash

USERID=$1
GROUPID=$2

yum remove -y gdal-devel
yum localinstall -y /tmp/rpmbuild/RPMS/x86_64/proj493-4.9.3-33.x86_64.rpm /tmp/rpmbuild/RPMS/x86_64/freetype2-2.8-33.x86_64.rpm /tmp/rpmbuild/RPMS/x86_64/boost162-1_62_0-33.x86_64.rpm /tmp/rpmbuild/RPMS/x86_64/gdal213-2.1.3-33.x86_64.rpm
ldconfig

cd /tmp
tar axvf /tmp/rpmbuild/SOURCES/mapbox-geometry-v0.9.2.tar.gz
tar axvf /tmp/rpmbuild/SOURCES/mapbox-variant-v1.1.3.tar.gz
cp -r geometry.hpp-0.9.2/include/mapbox /usr/local/include
cp -r variant-1.1.3/include/mapbox /usr/local/include
cd /tmp/rpmbuild
chown -R root:root /tmp/rpmbuild/SOURCES/mapnik-093fcee6d1ba1fd360718ceade83894aeffc2548.zip
rpmbuild -v -bb --clean SPECS/mapnik.spec
chown -R $USERID:$GROUPID /tmp/rpmbuild
