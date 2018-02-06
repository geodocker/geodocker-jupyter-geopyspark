#!/usr/bin/env bash

USERID=$1
GROUPID=$2

cd /wheel
pip3.4 wheel -r requirements.txt
chown -R $USERID:$GROUPID .
