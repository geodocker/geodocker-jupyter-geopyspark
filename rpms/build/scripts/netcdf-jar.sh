#!/usr/bin/env bash

USERID=$1
GROUPID=$2
JAR=$3

set -x
unzip -q /archives/s3+hdfs.zip
cd thredds-feature-s3-hdfs
./gradlew assemble
cp -f build/libs/$JAR /archives
set +x

chown -R $USERID:$GROUPID /archives ~/.m2 ~/.gradle
