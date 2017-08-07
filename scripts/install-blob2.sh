#!/usr/bin/env bash

PYTHONBLOB=$1

set -x

# Untar GeoPySpark
mkdir -p $HOME/.local/lib/python3.4/site-packages
mkdir -p $HOME/tmp-build
cd $HOME/tmp-build
tar axf /blobs/$PYTHONBLOB
# We need to append the egg paths if they exist
if [ -f "easy-install.pth" ]; then
    cat easy-install.pth >> $HOME/.local/lib/python3.4/site-packages/easy-install.pth
    rm easy-install.pth
fi
cp -r * $HOME/.local/lib/python3.4/site-packages
cd $HOME
rm -r $HOME/tmp-build
set +x
