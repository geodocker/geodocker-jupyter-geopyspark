#!/usr/bin/env bash

USERID=$1
GROUPID=$2

yum install -y geos-devel lcms2-devel libpng-devel openjpeg-devel zlib-devel
yum localinstall -y /tmp/rpmbuild/RPMS/x86_64/proj493-4.9.3-33.x86_64.rpm
ldconfig

cd /tmp/rpmbuild
chown -R root:root /tmp/rpmbuild/SOURCES/gdal-2.1.3.tar.gz
rpmbuild -v -bb --clean SPECS/gdal.spec
chown -R $USERID:$GROUPID /tmp/rpmbuild
