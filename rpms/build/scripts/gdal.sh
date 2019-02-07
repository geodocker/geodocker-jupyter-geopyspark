#!/usr/bin/env bash

USERID=$1
GROUPID=$2

yum install -y geos-devel lcms2-devel libcurl-devel libpng-devel zlib-devel swig
yum localinstall -y /tmp/rpmbuild/RPMS/x86_64/proj493-4.9.3-33.x86_64.rpm /tmp/rpmbuild/RPMS/x86_64/hdf5-1.8.20-33.x86_64.rpm /tmp/rpmbuild/RPMS/x86_64/netcdf-4.5.0-33.x86_64.rpm /tmp/rpmbuild/RPMS/x86_64/openjpeg230-2.3.0-33.x86_64.rpm
ldconfig

curl -o /tmp/ant.zip -L http://apache.spinellicreations.com//ant/binaries/apache-ant-1.9.13-bin.zip
unzip -d /tmp/apache-ant /tmp/ant.zip
export ANT_HOME=/tmp/apache-ant/apache-ant-1.9.13
export PATH=$PATH:$ANT_HOME/bin

cd /tmp/rpmbuild
chown -R root:root /tmp/rpmbuild/SOURCES/gdal-2.3.1.tar.gz
rpmbuild -v -bb --clean SPECS/gdal.spec
chown -R $USERID:$GROUPID /tmp/rpmbuild
