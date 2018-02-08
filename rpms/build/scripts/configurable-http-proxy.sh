#!/usr/bin/env bash

USERID=$1
GROUPID=$2

yum install -y /tmp/rpmbuild/RPMS/x86_64/nodejs-8.5.0-13.x86_64.rpm
ldconfig

cd /tmp/rpmbuild
chown -R root:root /tmp/rpmbuild/SOURCES/configurable-http-proxy.tar
rpmbuild -v -bb --clean SPECS/configurable-http-proxy.spec
chown -R $USERID:$GROUPID /tmp/rpmbuild
