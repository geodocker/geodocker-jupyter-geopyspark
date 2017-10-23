#!/usr/bin/env bash

USERID=$1
GROUPID=$2

yum install -y automake curl-devel fuse fuse-devel libxml2-devel mailcap openssl-devel
ldconfig

cd /tmp/rpmbuild
chown -R root:root /tmp/rpmbuild/SOURCES/v1.82.tar.gz
rpmbuild -v -bb --clean SPECS/s3fs.spec
chown -R $USERID:$GROUPID /tmp/rpmbuild
