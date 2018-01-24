#!/usr/bin/env bash

USER=$1
GROUP=$2
BLOB=$3
GEOPYSPARK_SHA=$4

# Aquire
chown -R root:root $HOME/.local

set -x

# Install GeoPySpark
pip3 install --user "https://github.com/locationtech-labs/geopyspark/archive/${GEOPYSPARK_SHA}.zip"

set +x

# Archive Libraries
cd $HOME/.local/lib/python3.4/site-packages
tar acf /archives/$BLOB $(find | grep geopyspark)

# Release
chown -R $USER:$GROUP /archives $HOME/.local
