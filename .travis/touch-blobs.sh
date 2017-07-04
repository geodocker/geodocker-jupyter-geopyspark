#!/usr/bin/env bash

set -x

if [ $(tar atf archives/gdal-and-friends.tar.gz | wc -l) == "677" ]; then
    touch archives/gdal-and-friends.tar.gz
fi

if [ $(unzip -l archives/netcdfAll-5.0.0-SNAPSHOT.jar | wc -l) == "11418" ]; then
    touch archives/netcdfAll-5.0.0-SNAPSHOT.jar
fi
