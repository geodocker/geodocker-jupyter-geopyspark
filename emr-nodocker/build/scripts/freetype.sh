#!/usr/bin/env bash

USERID=$1
GROUPID=$2

yum remove -y freetype freetype-devel
ldconfig

cd /tmp
tar axvf /archives/rpmbuild.tar
cd rpmbuild
cp /archives/freetype-2.8.tar.gz SOURCES/
rpmbuild -v -bb --clean SPECS/freetype.spec
cp -f RPMS/x86_64/*.rpm /archives/
chown -R $USERID:$GROUPID /archives/*
