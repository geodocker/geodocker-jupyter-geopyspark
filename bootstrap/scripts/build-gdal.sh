#!/usr/bin/env bash

USERID=$1
GROUPID=$2

export CPPFLAGS="-I/usr/local/include"
export CFLAGS="-I/usr/local/include"
export LDFLAGS="-I/usr/local/lib"

# ensure
mkdir -p $HOME/local/src
cd $HOME/local/src
rm -rf /usr/local/*

# untar source
for archive in zlib-1.2.11.tar.gz libpng-1.6.30.tar.xz geos-3.6.1.tar.bz2 proj-4.9.3.tar.gz lcms2-2.8.tar.gz openjpeg-v2.1.2.tar.gz gdal-2.1.3.tar.gz
do
    tar axvfk /archives/$archive
done

# build zlib
cd $HOME/local/src/zlib-1.2.11
./configure --prefix=/usr/local && make -j 33 && make install

# build libpng
cd $HOME/local/src/libpng-1.6.30
./configure --prefix=/usr/local && make -j 33 && make install

# build geos
cd $HOME/local/src/geos-3.6.1
./configure --prefix=/usr/local && make -j 33 && make install

# build proj4
cd $HOME/local/src/proj-4.9.3
./configure --prefix=/usr/local && make -j 33 && make install

# build lcms2
cd $HOME/local/src/lcms2-2.8
./configure --prefix=/usr/local && make -j 33 && make install

# build openjpeg
cd $HOME/local/src/openjpeg-2.1.2
mkdir -p build
cd build
cmake -DCMAKE_C_FLAGS="-I/usr/local/include -L/usr/local/lib" -DCMAKE_INSTALL_PREFIX="/usr/local" ..
make -j 33
make install

# build gdal
cd $HOME/local/src/gdal-2.1.3
./configure --prefix=/usr/local && (make -k -j 33 || make) && make install

# archive binaries
cd /usr/local
tar acvf /archives/gdal-and-friends.tar.gz .

# permissions
chown -R $USERID:$GROUPID /archives
