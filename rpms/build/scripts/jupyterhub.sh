#!/usr/bin/env bash

USERID=$1
GROUPID=$2
RPM=$3

yum install -y /tmp/rpmbuild/RPMS/x86_64/nodejs-8.5.0-13.x86_64.rpm /tmp/rpmbuild/RPMS/x86_64/$RPM
ldconfig
npm install -g configurable-http-proxy

cd /tmp/rpmbuild
chown -R root:root /tmp/rpmbuild/SOURCES/jupyterhub.tar
rpmbuild -v -bb --clean SPECS/jupyterhub.spec
chown -R $USERID:$GROUPID /tmp/rpmbuild
