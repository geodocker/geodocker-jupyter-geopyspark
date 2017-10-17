#!/usr/bin/env bash

USERID=$1
GROUPID=$2

cd /tmp/rpmbuild
chown -R root:root /tmp/rpmbuild/SOURCES/gcc-6.4.0.tar.xz
rpmbuild -v -bb --clean SPECS/gcc6.spec
chown -R $USERID:$GROUPID /tmp/rpmbuild
