#!/usr/bin/env bash

USERID=$1
GROUPID=$2

yum remove -y gdal-devel
yum localinstall -y /archives/proj-4.9.3-33.x86_64.rpm

cd /tmp
tar axvf /archives/rpmbuild.tar
cd rpmbuild
cp /archives/gdal-2.1.3.tar.gz SOURCES/
rpmbuild -v -bb --clean SPECS/gdal.spec
cp -f RPMS/x86_64/*.rpm /archives/
chown -R $USERID:$GROUPID /archives/*
