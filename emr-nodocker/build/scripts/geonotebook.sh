#!/usr/bin/env bash

USERID=$1
GROUPID=$2
GEOPYSPARK_RPM=$3

yum install -y \
    /tmp/rpmbuild/RPMS/x86_64/$GEOPYSPARK_RPM \
    /tmp/rpmbuild/RPMS/x86_64/nodejs-8.5.0-13.x86_64.rpm /tmp/rpmbuild/RPMS/x86_64/jupyterhub-0.7.2-13.x86_64.rpm \
    /tmp/rpmbuild/RPMS/x86_64/freetype2-2.8-33.x86_64.rpm /tmp/rpmbuild/RPMS/x86_64/proj493-4.9.3-33.x86_64.rpm /tmp/rpmbuild/RPMS/x86_64/gdal213-2.1.3-33.x86_64.rpm \
    /tmp/rpmbuild/RPMS/x86_64/boost162-lib-1_62_0-33.x86_64.rpm /tmp/rpmbuild/RPMS/x86_64/mapnik-093fcee-33.x86_64.rpm /tmp/rpmbuild/RPMS/x86_64/python-mapnik-e5f107d-33.x86_64.rpm
ldconfig

cd /tmp/rpmbuild
chown -R root:root /tmp/rpmbuild/SOURCES/geonotebook.tar
rpmbuild -v -bb --clean SPECS/geonotebook.spec
chown -R $USERID:$GROUPID /tmp/rpmbuild
