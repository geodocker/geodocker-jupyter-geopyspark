#!/usr/bin/env bash

USERID=$1
GROUPID=$2

yum install -y libcurl-devel
ldconfig

cd /tmp/rpmbuild
chown -R root:root /tmp/rpmbuild/SOURCES/hdf5-1.8.20.tar.bz2
rpmbuild -v -bb --clean SPECS/hdf5.spec
chown -R $USERID:$GROUPID /tmp/rpmbuild
