#!/usr/bin/env bash

USERID=$1
GROUPID=$2

yum localinstall -y /archives/boost-1_59_0-33.x86_64.rpm
cd /tmp
tar axvf /archives/rpmbuild.tar
cd rpmbuild
cp /archives/mapnik-v3.0.13.tar.bz2 SOURCES/
rpmbuild -v -bb --clean SPECS/mapnik.spec
cp -f RPMS/x86_64/*.rpm /archives/
chown -R $USERID:$GROUPID /archives/*
