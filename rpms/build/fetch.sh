#!/usr/bin/env bash

if [ ! -z "$1" ]
then
    URI=$(echo $1 | sed 's,/$,,')
    make src
    aws s3 sync $URI rpmbuild/RPMS/x86_64/
    mv -f rpmbuild/RPMS/x86_64/gdal-and-friends.tar.gz blobs/
    touch blobs/gdal-and-friends.tar.gz
    touch rpmbuild/RPMS/x86_64/*.rpm
    touch rpmbuild/RPMS/x86_64/hdf5-*.rpm
    touch rpmbuild/RPMS/x86_64/netcdf-*.rpm
    touch rpmbuild/RPMS/x86_64/gdal213-*.rpm
    touch rpmbuild/RPMS/x86_64/jupyterhub-*.rpm
    touch rpmbuild/RPMS/x86_64/mapnik-*.rpm
    touch rpmbuild/RPMS/x86_64/python-mapnik-*.rpm
    touch rpmbuild/RPMS/x86_64/geonotebook-*.rpm
fi
