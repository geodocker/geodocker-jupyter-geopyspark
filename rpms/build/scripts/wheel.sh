#!/usr/bin/env bash

USERID=$1
GROUPID=$2

yum localinstall -y \
    /tmp/rpmbuild/RPMS/x86_64/proj493-4.9.3-33.x86_64.rpm \
    /tmp/rpmbuild/RPMS/x86_64/hdf5-1.8.20-33.x86_64.rpm \
    /tmp/rpmbuild/RPMS/x86_64/netcdf-4.5.0-33.x86_64.rpm \
    /tmp/rpmbuild/RPMS/x86_64/gdal231-2.3.1-33.x86_64.rpm \
ldconfig

mkdir -p /usr/share/jupyter/kernels
mkdir /tmp/wheel
cd /tmp/wheel
cp /wheel/requirements.txt .
export CC=gcc48
pip3.4 install numpy==1.12.1
pip3.4 wheel -r requirements.txt
pip3.4 install ipython==5.1.0 /archives/ipykernel.zip
pip3.4 wheel ipython==5.1.0 /archives/ipykernel.zip

chown -R $USERID:$GROUPID .

# Clean up duplicate packages (leave most recent version)
rm -f tornado-5*
rm -f pyzmq-17*
for f in $(ls -1r | sed -e 's/^\(.*\)$/\1 \1/' | sed -e 's/^\([a-zA-Z0-9_]*\)-[0-9].* \(.*\)$/\1 \2/' | awk '{ if (seen[$1]++){print $2} }')
do
    echo "rm -f $f"
    rm -f $f
done

echo "Final wheel list: =============================================="
ls -1r

cp *.whl /wheel
