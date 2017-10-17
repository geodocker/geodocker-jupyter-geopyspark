#!/usr/bin/env bash

USERID=$1
GROUPID=$2

cd /tmp/rpmbuild
chown -R root:root /tmp/rpmbuild/SOURCES/geopyspark.tar
rpmbuild -v -bb --clean SPECS/geopyspark.spec
chown -R $USERID:$GROUPID /tmp/rpmbuild
