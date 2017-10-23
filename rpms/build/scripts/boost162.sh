#!/usr/bin/env bash

USERID=$1
GROUPID=$2

ldconfig

cd /tmp/rpmbuild
chown -R root:root /tmp/rpmbuild/SOURCES/boost_1_62_0.tar.bz2
rpmbuild -v -bb --clean SPECS/boost162.spec
chown -R $USERID:$GROUPID /tmp/rpmbuild
