#!/usr/bin/env bash

USERID=$1
GROUPID=$2

yum install -y \
    /tmp/rpmbuild/RPMS/x86_64/geopyspark-deps-0.0.0-13.x86_64.rpm \
    /tmp/rpmbuild/RPMS/x86_64/nodejs-8.5.0-13.x86_64.rpm \
    /tmp/rpmbuild/RPMS/x86_64/freetype2-2.8-33.x86_64.rpm \
    /tmp/rpmbuild/RPMS/x86_64/proj493-4.9.3-33.x86_64.rpm \
    /tmp/rpmbuild/RPMS/x86_64/hdf5-1.8.20-33.x86_64.rpm \
    /tmp/rpmbuild/RPMS/x86_64/netcdf-4.5.0-33.x86_64.rpm \
    /tmp/rpmbuild/RPMS/x86_64/gdal213-2.1.3-33.x86_64.rpm

ldconfig
npm install -g configurable-http-proxy

cd /tmp/rpmbuild
chown -R root:root /tmp/rpmbuild/SOURCES/jupyterhub.tar
rpmbuild -v -bb --clean SPECS/jupyterhub.spec
chown -R $USERID:$GROUPID /tmp/rpmbuild
