#!/usr/bin/env bash

USERID=$1
GROUPID=$2

export LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64

cd /tmp
tar axvf /archives/rpmbuild.tar
cd rpmbuild
cp /archives/node-v8.5.0.tar.gz  SOURCES/
rpmbuild -v -bb --clean SPECS/nodejs.spec
cp -f RPMS/x86_64/*.rpm /archives/
chown -R $USERID:$GROUPID /archives/*
