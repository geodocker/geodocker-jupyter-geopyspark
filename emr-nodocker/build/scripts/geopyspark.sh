#!/usr/bin/env bash

USERID=$1
GROUPID=$2

cd /tmp
tar axvf /archives/rpmbuild.tar
cd rpmbuild
cp /archives/geopyspark.tar SOURCES/
rpmbuild -v -bb --clean SPECS/geopyspark.spec
cp -f RPMS/x86_64/*.rpm /archives/
chown -R $USERID:$GROUPID /archives/*
