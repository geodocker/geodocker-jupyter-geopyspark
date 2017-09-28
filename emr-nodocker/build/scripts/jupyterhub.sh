#!/usr/bin/env bash

USERID=$1
GROUPID=$2
RPM=$3

yum install -y /archives/nodejs-8.5.0-13.x86_64.rpm /archives/$RPM
ldconfig
npm install -g configurable-http-proxy

cd /tmp
tar axvf /archives/rpmbuild.tar
cd rpmbuild
cp /archives/jupyterhub.tar SOURCES/
rpmbuild -v -bb --clean SPECS/jupyterhub.spec
cp -f RPMS/x86_64/*.rpm /archives/
chown -R $USERID:$GROUPID /archives/*
