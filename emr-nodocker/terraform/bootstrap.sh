#!/bin/bash

BUCKET=$1

# Parses a configuration file put in place by EMR to determine the role of this node
is_master() {
  if [ $(jq '.isMaster' /mnt/var/lib/info/instance.json) = 'true' ]; then
    return 0
  else
    return 1
  fi
}

if is_master; then
    # Download packages
    for i in boost162-lib-1_62_0-33.x86_64.rpm freetype2-lib-2.8-33.x86_64.rpm gcc6-lib-6.4.0-33.x86_64.rpm gdal213-lib-2.1.3-33.x86_64.rpm geonotebook-0.0.0-13.x86_64.rpm geopyspark-0.2.2-13.x86_64.rpm jupyterhub-0.7.2-13.x86_64.rpm mapnik-093fcee-33.x86_64.rpm nodejs-8.5.0-13.x86_64.rpm proj493-lib-4.9.3-33.x86_64.rpm python-mapnik-e5f107d-33.x86_64.rpm
    do
	aws s3 cp $BUCKET/$i /tmp/$i
    done

    # Install packages
    cd /tmp
    sudo yum localinstall -y boost162-lib-1_62_0-33.x86_64.rpm freetype2-lib-2.8-33.x86_64.rpm gcc6-lib-6.4.0-33.x86_64.rpm gdal213-lib-2.1.3-33.x86_64.rpm geonotebook-0.0.0-13.x86_64.rpm geopyspark-0.2.2-13.x86_64.rpm jupyterhub-0.7.2-13.x86_64.rpm mapnik-093fcee-33.x86_64.rpm nodejs-8.5.0-13.x86_64.rpm proj493-lib-4.9.3-33.x86_64.rpm python-mapnik-e5f107d-33.x86_64.rpm
    rm -f /tmp/*.rpm

    # To ensure `pkg_resources` package, may not be needed
    sudo pip-3.4 install --upgrade pip

    # Install GeoPySpark + GeoNotebook kernel
    cat <<EOF > /tmp/kernel.json
{
    "language": "python",
    "display_name": "GeoNotebook + GeoPySpark",
    "argv": [
        "/usr/bin/python3.4",
        "-m",
        "geonotebook",
        "-f",
        "{connection_file}"
    ],
    "env": {
        "PYSPARK_PYTHON": "/usr/bin/python3.4",
        "SPARK_HOME": "/usr/lib/spark",
        "PYTHONPATH": "/usr/lib/spark/python/lib/pyspark.zip:/usr/lib/spark/python/lib/py4j-0.10.4-src.zip",
        "GEOPYSPARK_JARS_PATH": "/opt/jars",
        "YARN_CONF_DIR": "/etc/hadoop/conf",
        "PYSPARK_SUBMIT_ARGS": "--conf hadoop.yarn.timeline-service.enabled=false pyspark-shell"
    }
}
EOF
    sudo cp /tmp/kernel.json /usr/share/jupyter/kernels/geonotebook3/kernel.json
    rm -f /tmp/kernel.json

    # Linkage
    echo '/usr/local/lib' > /tmp/local.conf
    echo '/usr/local/lib64' >> /tmp/local.conf
    sudo cp /tmp/local.conf /etc/ld.so.conf.d/local.conf
    sudo ldconfig
    rm -f /tmp/local.conf

    # Set password
    echo 'hadoop:hadoop' | sudo chpasswd

    # Execute
    export PATH=/usr/local/bin:$PATH
    jupyterhub --no-ssl --Spawner.notebook_dir=/home/hadoop &
else
    # Download packages
    for i in freetype2-lib-2.8-33.x86_64.rpm gcc6-lib-6.4.0-33.x86_64.rpm gdal213-lib-2.1.3-33.x86_64.rpm geopyspark-worker-0.2.2-13.x86_64.rpm proj493-lib-4.9.3-33.x86_64.rpm
    do
	aws s3 cp $BUCKET/$i /tmp/$i
    done

    # Install packages
    cd /tmp
    sudo yum localinstall -y freetype2-lib-2.8-33.x86_64.rpm gcc6-lib-6.4.0-33.x86_64.rpm gdal213-lib-2.1.3-33.x86_64.rpm geopyspark-worker-0.2.2-13.x86_64.rpm proj493-lib-4.9.3-33.x86_64.rpm
    rm -f /tmp/*.rpm

    # To ensure `pkg_resources` package, may not be needed
    sudo pip-3.4 install --upgrade pip

    # Linkage
    echo '/usr/local/lib' > /tmp/local.conf
    echo '/usr/local/lib64' >> /tmp/local.conf
    sudo cp /tmp/local.conf /etc/ld.so.conf.d/local.conf
    sudo ldconfig
    rm -f /tmp/local.conf
fi
