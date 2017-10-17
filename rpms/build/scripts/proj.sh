#!/usr/bin/env bash

USERID=$1
GROUPID=$2

ldconfig

cd /tmp/rpmbuild
chown -R root:root /tmp/rpmbuild/SOURCES/proj-4.9.3.tar.gz
rpmbuild -v -bb --clean SPECS/proj.spec
chown -R $USERID:$GROUPID /tmp/rpmbuild
