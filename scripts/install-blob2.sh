#!/usr/bin/env bash

PYTHONBLOB=$1

set -x

# Untar GeoPySpark
mkdir -p $HOME/.local/lib/python3.4/site-packages
cd $HOME/.local/lib/python3.4/site-packages
tar axf /blobs/$PYTHONBLOB

set +x
