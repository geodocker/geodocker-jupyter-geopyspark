#!/usr/bin/env bash

PYTHONBLOB=$1

set -x

# Untar GDAL and friends
mkdir -p $HOME/local/gdal
cd $HOME/local/gdal
tar axf /blobs/gdal-and-friends.tar.gz

# Untar GeoPySpark dependencies 
mkdir -p $HOME/.local/lib/python3.4/site-packages
cd $HOME/.local/lib/python3.4/site-packages
tar axf /blobs/$PYTHONBLOB

set +x
