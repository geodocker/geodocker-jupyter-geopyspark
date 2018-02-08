#!/usr/bin/env bash

if [ ! -z "$1" ]
then
    URI=$(echo $1 | sed 's,/$,,')/$(git rev-parse HEAD)/
    aws s3 sync rpmbuild/RPMS/x86_64/ $URI
    aws s3 sync wheel/ $URI
else
    echo "Need location"
fi
