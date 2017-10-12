#!/usr/bin/env bash

USERID=$1
GROUPID=$2

yum remove -y freetype freetype-devel
ldconfig

cd /tmp/rpmbuild
chown -R root:root /tmp/rpmbuild/SOURCES/freetype-2.8.tar.gz
rpmbuild -v -bb --clean SPECS/freetype.spec
chown -R $USERID:$GROUPID /tmp/rpmbuild
