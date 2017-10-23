#!/usr/bin/env bash

USERID=$1
GROUPID=$2

ldconfig

cd /tmp/rpmbuild
chown -R root:root /tmp/rpmbuild/SOURCES/node-v8.5.0.tar.gz
rpmbuild -v -bb --clean SPECS/nodejs.spec
chown -R $USERID:$GROUPID /tmp/rpmbuild
