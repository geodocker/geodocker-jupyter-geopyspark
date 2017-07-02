#!/usr/bin/env bash

USER=$1
GROUP=$2
BLOB=$3

cp -f /blobs/${BLOB} /archives/
chown -R $USER:$GROUP /archives
