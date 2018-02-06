#!/usr/bin/env bash

USERID=$1
GROUPID=$2

yum localinstall -y \
    /tmp/rpmbuild/RPMS/x86_64/proj493-4.9.3-33.x86_64.rpm \
    /tmp/rpmbuild/RPMS/x86_64/freetype2-2.8-33.x86_64.rpm \
    /tmp/rpmbuild/RPMS/x86_64/boost162-1_62_0-33.x86_64.rpm \
    /tmp/rpmbuild/RPMS/x86_64/hdf5-1.8.20-33.x86_64.rpm \
    /tmp/rpmbuild/RPMS/x86_64/netcdf-4.5.0-33.x86_64.rpm \
    /tmp/rpmbuild/RPMS/x86_64/gdal213-2.1.3-33.x86_64.rpm \
    /tmp/rpmbuild/RPMS/x86_64/mapnik-093fcee-33.x86_64.rpm
ldconfig

cd /tmp
tar axvf /tmp/rpmbuild/SOURCES/mapbox-geometry-v0.9.2.tar.gz
tar axvf /tmp/rpmbuild/SOURCES/mapbox-variant-v1.1.3.tar.gz
cp -r geometry.hpp-0.9.2/include/mapbox /usr/local/include
cp -r variant-1.1.3/include/mapbox /usr/local/include

cd /wheel
pip3.4 install numpy==1.12.1
pip3.4 wheel -r requirements.txt
pip3.4 install ipython==5.1.0 /archives/ipykernel.zip
pip3.4 wheel ipython==5.1.0 /archives/ipykernel.zip
chown -R $USERID:$GROUPID .
