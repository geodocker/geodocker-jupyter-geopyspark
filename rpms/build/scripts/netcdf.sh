#!/usr/bin/env bash

USERID=$1
GROUPID=$2

yum install -y libcurl-devel
yum localinstall -y /tmp/rpmbuild/RPMS/x86_64/proj493-4.9.3-33.x86_64.rpm /tmp/rpmbuild/RPMS/x86_64/hdf5-1.8.20-33.x86_64.rpm
ldconfig

cd /tmp/rpmbuild
chown -R root:root /tmp/rpmbuild/SOURCES/netcdf-4.5.0.tar.gz
rpmbuild -v -bb --clean SPECS/netcdf.spec
chown -R $USERID:$GROUPID /tmp/rpmbuild
