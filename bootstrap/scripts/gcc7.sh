#!/usr/bin/env bash

USERID=$1
GROUPID=$2

cd /tmp
tar axvf /archives/rpmbuild.tar
cd rpmbuild
cp /archives/gcc-7.1.0.tar.bz2 SOURCES/
rpmbuild -v -bb --clean SPECS/gcc7.spec
cp -f RPMS/x86_64/*.rpm /archives/
chown -R $USERID:$GROUPID /archives/*
