#!/usr/bin/env bash

USERID=$1
GROUPID=$2

export CPPFLAGS="-I/usr/local/include"
export CFLAGS="-I/usr/local/include"
export LDFLAGS="-L/usr/local/lib -L/usr/local/lib64"
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib:/usr/local/lib64

yum remove -y \
    bzip2-devel \
    cairo-devel \
    gmp-devel \
    harfbuzz-devel \
    libicu-devel \
    libjpeg-turbo-devel \
    libmpc-devel \
    libpng-devel \
    libtiff-devel \
    libwebp-devel \
    libxml2-devel \
    mpfr-devel \
    zlib-devel

# ensure
mkdir -p $HOME/local/src
cd $HOME/local/src
rm -rf /usr/local/*

# untar source
for archive in curl-7.57.0.tar.bz2 zlib-1.2.11.tar.gz libpng-1.6.30.tar.xz geos-3.6.1.tar.bz2 proj-4.9.3.tar.gz lcms2-2.8.tar.gz openjpeg-v2.1.2.tar.gz gdal-2.1.3.tar.gz
do
    tar axvfk /src/$archive
done

# build curl
cd $HOME/local/src/curl-7.57.0
./configure --prefix=/usr/local && make -j && make install

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
tar acvf /blobs/gdal-and-friends.tar.gz .

# permissions
chown -R $USERID:$GROUPID /blobs
