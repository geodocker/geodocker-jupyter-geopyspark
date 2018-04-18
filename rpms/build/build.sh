#!/usr/bin/env bash

if [ ! -z "$1" ]
then
    ./fetch.sh $1
fi

make gcc4
make rpms
make wheels
make base
