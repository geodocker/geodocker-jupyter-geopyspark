#!/usr/bin/env bash

if [ ! -z "$1" ]
then
    aws s3 sync rpmbuild/RPMS/x86_64/ $(echo $1 | sed 's,/$,,')/$(git rev-parse HEAD)/
else
    echo "Need location"
fi
