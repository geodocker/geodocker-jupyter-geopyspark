#!/usr/bin/env bash

USERID=$1
GROUPID=$2

yum localinstall -y \
    /tmp/rpmbuild/RPMS/x86_64/proj493-4.9.3-33.x86_64.rpm \
    /tmp/rpmbuild/RPMS/x86_64/hdf5-1.8.20-33.x86_64.rpm \
    /tmp/rpmbuild/RPMS/x86_64/netcdf-4.5.0-33.x86_64.rpm \
    /tmp/rpmbuild/RPMS/x86_64/gdal213-2.1.3-33.x86_64.rpm \
ldconfig

cd /wheel
export CC=gcc48
pip3.4 install numpy==1.12.1
pip3.4 wheel -r requirements.txt
pip3.4 install ipython==5.1.0 /archives/ipykernel.zip
pip3.4 wheel ipython==5.1.0 /archives/ipykernel.zip
rm -f affine-2.0.0.post1-py3-none-any.whl \
   branca-0.2.0-py3-none-any.whl \
   decorator-4.0.10-py2.py3-none-any.whl \
   decorator-4.2.1-py2.py3-none-any.whl \
   gcsfs-0.0.5-py3-none-any.whl \
   gcsfs-0.0.6-py3-none-any.whl \
   google_auth-1.4.0-py2.py3-none-any.whl \
   ipykernel-4.7.0.dev0-py3-none-any.whl \
   ipykernel-4.8.0-py3-none-any.whl \
   ipykernel-4.8.1-py3-none-any.whl \
   ipython_genutils-0.2.0-py2.py3-none-any.whl \
   jupyter_client-5.2.2-py2.py3-none-any.whl \
   jupyter_client-4.4.0-py2.py3-none-any.whl \
   jupyter_core-4.4.0-py2.py3-none-any.whl \
   matplotlib-2.0.0-1-cp34-cp34m-manylinux1_x86_64.whl \
   numpy-1.12.1-cp34-cp34m-manylinux1_x86_64.whl \
   oauthlib-2.0.6-py2.py3-none-any.whl \
   pbr-3.1.1-py2.py3-none-any.whl \
   pexpect-4.4.0-py2.py3-none-any.whl \
   pexpect-4.2.1-py2.py3-none-any.whl \
   pexpect-4.3.1-py2.py3-none-any.whl \
   prompt_toolkit-1.0.15-py3-none-any.whl \
   protobuf-3.1.0-py2.py3-none-any.whl \
   ptyprocess-0.5.2-py2.py3-none-any.whl \
   Pygments-2.2.0-py2.py3-none-any.whl \
   python_dateutil-2.6.0-py2.py3-none-any.whl \
   python_dateutil-2.6.1-py2.py3-none-any.whl \
   python_dateutil-2.7.0-py2.py3-none-any.whl \
   pyzmq-16.0.2-cp34-cp34m-manylinux1_x86_64.whl \
   pyzmq-16.0.4-cp34-cp34m-manylinux1_x86_64.whl \
   s3fs-0.1.3-py2.py3-none-any.whl \
   s3fs-0.1.4-py3-none-any.whl \
   setuptools-18.5-py2.py3-none-any.whl \
   setuptools-38.5.2-py2.py3-none-any.whl \
   setuptools-39.0.1-py2.py3-none-any.whl \
   simplegeneric-0.8.1-py3-none-any.whl \
   six-1.11.0-py2.py3-none-any.whl \
   tornado-5.0-cp34-cp34m-linux_x86_64.whl \
   tornado-5.0.2-cp34-cp34m-linux_x86_64.whl \
   traitlets-4.3.1-py2.py3-none-any.whl
chown -R $USERID:$GROUPID .
