#!/usr/bin/env bash

USER=$1
GROUP=$2
BLOB=$3

export CPPFLAGS="-I$HOME/local/gdal/include"
export CFLAGS="-I$HOME/local/gdal/include"
export LDFLAGS="-I$HOME/local/gdal/lib"

# aquire
chown -R root:root $HOME/.cache/pip $HOME/.local

set -x

# install geopsypark's friends
cat <<EOF > /tmp/geopyspark_deps.txt
appdirs==1.4.3
numpy==1.12.1
packaging==16.8
protobuf==3.3.0
pyparsing==2.2.0
rasterio==1.0a7
Shapely==1.6b4
six==1.10.0
EOF
pip3 install --user -r /tmp/geopyspark_deps.txt &> /dev/null

# install geonotebook's friends
PATH=$PATH:$HOME/local/gdal/bin pip3 install --user GDAL==2.1.3
pip3 install --user requests==2.11.1 &> /dev/null
pip3 install --user promise==0.4.2 &> /dev/null
pip3 install --user fiona==1.7.1 &> /dev/null
pip3 install --user matplotlib==2.0.0 &> /dev/null
CFLAGS='-DPI=M_PI -DHALFPI=M_PI_2 -DFORTPI=M_PI_4 -DTWOPI=(2*M_PI) -I$HOME/local/gdal/include' pip3 install --user pyproj==1.9.5.1 &> /dev/null

# install geonotebook's other friends
cat <<EOF > /tmp/geonotebook_deps.txt
affine==2.0.0.post1
alembic==0.8.9
backports-abc==0.5
bleach==1.5.0
click==6.7
click-plugins==1.0.3
cligj==0.4.0
colortools==0.1.2
cycler==0.10.0
decorator==4.0.10
entrypoints==0.2.2
gevent==1.2.1
html5lib==0.9999999
itsdangerous==0.24
Jinja2==2.9.4
jsonschema==2.5.1
jupyter-client==4.4.0
jupyter-core==4.2.1
jupyterhub==0.7.2
lxml==3.7.3
Mako==1.0.6
MarkupSafe==0.23
mistune==0.7.3
munch==2.1.1
networkx==1.11
olefile==0.44
pamela==0.3.0
pandas==0.19.2
pandocfilters==1.4.1
pexpect==4.2.1
pickleshare==0.7.4
Pillow==4.1.0
prompt-toolkit==1.0.9
ptyprocess==0.5.1
Pygments==2.1.3
pyproj==1.9.5.1
python-dateutil==2.6.0
python-editor==1.0.3
pytz==2017.2
PyWavelets==0.5.2
pyzmq==16.0.2
scikit-image==0.13.0
scipy==0.19.0
simplegeneric==0.8.1
snuggs==1.4.1
SQLAlchemy==1.1.4
terminado==0.6
testpath==0.3
traitlets==4.3.1
wcwidth==0.1.7
EOF
pip3 install --user -r /tmp/geonotebook_deps.txt &> /dev/null

set +x

# archive libraries
cd $HOME/.local/lib/python3.4/site-packages
touch .xxx
tar acf /archives/$BLOB $(find | grep -v geopyspark)

# release
chown -R $USER:$GROUP $HOME/.cache/pip $HOME/.local
