#!/usr/bin/env bash

USERID=$1
GROUPID=$2

yum install -y lcms2-devel libcurl-devel zlib-devel
ldconfig

cd /tmp/rpmbuild
chown -R root:root /tmp/rpmbuild/SOURCES/openjpeg-2.3.0.tar.gz
rpmbuild -v -bb --clean SPECS/openjpeg.spec
chown -R $USERID:$GROUPID /tmp/rpmbuild
