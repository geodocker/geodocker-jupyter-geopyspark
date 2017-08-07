#!/usr/bin/env bash

USERID=$1
GROUPID=$2

yum install -y \
    boost-devel \
    cairo-devel \
    freetype-devel \
    gcc \
    gcc-c++ \
    gdal-devel \
    harfbuzz-devel \
    libicu-devel \
    libjpeg-turbo-devel \
    libpng-devel \
    libtiff-devel \
    libwebp-devel \
    libxml2-devel \
    pkgconfig \
    proj-devel \
    rpm-build \
    zlib-devel

cd /tmp
tar axvf /archives/mapnik.tar
cp /archives/mapnik-v3.0.15.tar.bz2 /tmp/mapnik/SOURCES/
cd /tmp/mapnik
rpmbuild -v -bb --clean SPECS/mapnik.spec
cp RPMS/x86_64/mapnik-v3.0.15-13.x86_64.rpm /archives/

chown -R $USERID:$GROUPID /archives

