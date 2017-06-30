#!/usr/bin/env bash

USER=$1
GROUP=$2
GEOPYSPARK=$3
GEONOTEBOOK=$4

export CPPFLAGS="-I$HOME/local/gdal/include"
export CFLAGS="-I$HOME/local/gdal/include"
export LDFLAGS="-I$HOME/local/gdal/lib"

# aquire
chown -R root:root $HOME/.local

# install geopsypark
cd $HOME
unzip /archives/geopyspark-${GEOPYSPARK}.zip
cd geopyspark-${GEOPYSPARK}
pip3 install --user .

# archive libraries
cd $HOME/.local/lib/python3.4/site-packages
tar acvf /archives/geopyspark-and-friends.tar.gz .

# release
chown -R $USER:$GROUP /archives $HOME/.local
