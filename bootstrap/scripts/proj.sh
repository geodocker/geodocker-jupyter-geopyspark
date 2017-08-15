#!/usr/bin/env bash

USERID=$1
GROUPID=$2

yum remove -y proj proj-devel

cd /tmp
tar axvf /archives/rpmbuild.tar
cd rpmbuild
cp /archives/proj-4.9.3.tar.gz SOURCES/
rpmbuild -v -bb --clean SPECS/proj.spec
cp -f RPMS/x86_64/*.rpm /archives/
chown -R $USERID:$GROUPID /archives/*
