#!/usr/bin/env bash

USERID=$1
GROUPID=$2
GEOPYSPARK_SHA=$3
GEOPYSPARK_JAR=$4
NETCDF_SHA=$5
NETCDF_JAR=$6

apt-get update
apt-get install -y make

set -x
unzip -q /archives/geopyspark-$GEOPYSPARK_SHA.zip
unzip -q /archives/geopyspark-netcdf-$NETCDF_SHA.zip
cd geopyspark-$GEOPYSPARK_SHA/
make build
cp -f geopyspark/jars/$GEOPYSPARK_JAR /archives
cd ../geopyspark-netcdf-$NETCDF_SHA/
CDM_JAR_DIR=/archives GEOPYSPARK_JAR_DIR=/archives make backend/gddp/target/scala-2.11/$NETCDF_JAR
cp -f backend/gddp/target/scala-2.11/$NETCDF_JAR /archives
set +x

chown -R $USERID:$GROUPID /archives ~/.m2 ~/.ivy2
