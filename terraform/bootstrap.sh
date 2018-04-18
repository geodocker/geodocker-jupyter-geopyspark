#!/bin/bash

RPM_URI=$(echo $1 | sed 's,/$,,')
NB_BUCKET=$(echo $2 | sed 's,s3://\([^/]*\).*,\1,')
NB_PREFIX=$(echo $2 | sed 's,s3://[^/]*/,,' | sed 's,/$,,')
OAUTH_MODULE=$3
OAUTH_CLASS=$4
OAUTH_CLIENT_ID=$5
OAUTH_CLIENT_SECRET=$6
GEOPYSPARKJARS=$7
GEOPYSPARKURI=$8

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
    mkdir -p /tmp/blobs/
    aws s3 sync $RPM_URI /tmp/blobs/

    # Install binary packages
    (cd /tmp/blobs; sudo yum localinstall -y gdal213-2.1.3-33.x86_64.rpm hdf5-1.8.20-33.x86_64.rpm netcdf-4.5.0-33.x86_64.rpm nodejs-8.5.0-13.x86_64.rpm proj493-lib-4.9.3-33.x86_64.rpm configurable-http-proxy-0.0.0-13.x86_64.rpm)

    # Install Python packages
    sudo pip-3.4 install --upgrade pip
    sudo ln -s /usr/local/bin/pip3 /usr/bin/
    sudo ln -s /usr/local/bin/pip3.4 /usr/bin/
    (cd /tmp/blobs ; sudo pip3.4 install *.whl)

    # Linkage
    echo '/usr/local/lib' > /tmp/local.conf
    echo '/usr/local/lib64' >> /tmp/local.conf
    sudo cp /tmp/local.conf /etc/ld.so.conf.d/local.conf
    sudo ldconfig
    rm -f /tmp/local.conf

    # Set up user account to manage JupyterHub
    sudo groupadd shadow
    sudo chgrp shadow /etc/shadow
    sudo chmod 640 /etc/shadow
    # sudo usermod -a -G shadow hadoop
    sudo useradd -G shadow -r hublauncher
    sudo groupadd jupyterhub

    # Ensure that all members of `jupyterhub` group may log in to JupyterHub
    echo 'hublauncher ALL=(%jupyterhub) NOPASSWD: /usr/local/bin/sudospawner' | sudo tee -a /etc/sudoers
    echo 'hublauncher ALL=(ALL) NOPASSWD: /usr/sbin/useradd' | sudo tee -a /etc/sudoers
    echo 'hublauncher ALL=(ALL) NOPASSWD: /bin/chown' | sudo tee -a /etc/sudoers
    echo 'hublauncher ALL=(ALL) NOPASSWD: /bin/mkdir' | sudo tee -a /etc/sudoers
    echo 'hublauncher ALL=(ALL) NOPASSWD: /bin/mv' | sudo tee -a /etc/sudoers
    echo 'hublauncher ALL=(hdfs) NOPASSWD: /usr/bin/hdfs' | sudo tee -a /etc/sudoers

    # Environment setup
    cat <<EOF > /tmp/oauth_profile.sh
export AWS_DNS_NAME=$(aws ec2 describe-network-interfaces --filters Name=private-ip-address,Values=$(hostname -i) | jq -r '.[] | .[] | .Association.PublicDnsName')
export OAUTH_CALLBACK_URL=http://\$AWS_DNS_NAME:8000/hub/oauth_callback
export OAUTH_CLIENT_ID=$OAUTH_CLIENT_ID
export OAUTH_CLIENT_SECRET=$OAUTH_CLIENT_SECRET

alias launch_hub='sudo -u hublauncher -E env "PATH=/usr/local/bin:$PATH" jupyterhub --JupyterHub.spawner_class=sudospawner.SudoSpawner --SudoSpawner.sudospawner_path=/usr/local/bin/sudospawner --Spawner.notebook_dir=/home/{username}'
EOF
    sudo mv /tmp/oauth_profile.sh /etc/profile.d
    . /etc/profile.d/oauth_profile.sh

    # Setup required scripts/configurations for launching JupyterHub
    cat <<EOF > /tmp/new_user
#!/bin/bash

export user=\$1

sudo useradd -m -G jupyterhub,hadoop \$user
sudo -u hdfs hdfs dfs -mkdir /user/\$user

sudo mkdir -p /home/\$user/.jupyter/

cat << LOL > /tmp/jupyter_notebook_config.py.\$user
from s3contents import S3ContentsManager

c.NotebookApp.contents_manager_class = S3ContentsManager
c.S3ContentsManager.bucket = "$NB_BUCKET"
c.S3ContentsManager.prefix = "$NB_PREFIX"

LOL

sudo mv /tmp/jupyter_notebook_config.py.\$user /home/\$user/.jupyter/jupyter_notebook_config.py
sudo chown \$user:\$user -R /home/\$user/.jupyter/

EOF
    chmod +x /tmp/new_user
    sudo chown root:root /tmp/new_user
    sudo mv /tmp/new_user /usr/local/bin

    cat <<EOF > /tmp/jupyterhub_config.py
from oauthenticator.$OAUTH_MODULE import $OAUTH_CLASS

c = get_config()

c.JupyterHub.authenticator_class = $OAUTH_CLASS
c.${OAUTH_CLASS}.create_system_users = True

c.JupyterHub.spawner_class='sudospawner.SudoSpawner'
c.SudoSpawner.sudospawner_path='/usr/local/bin/sudospawner'
c.Spawner.notebook_dir='/home/{username}'
c.LocalAuthenticator.add_user_cmd = ['new_user']

EOF

    # Install GeoPySpark
    if [[ $GEOPYSPARKURI == s3* ]]; then
	aws s3 cp $GEOPYSPARKURI /tmp/geopyspark.zip
	GEOPYSPARKURI=/tmp/geopyspark.zip
    fi
    sudo -E env "PATH=/usr/local/bin:$PATH" pip3.4 install "$GEOPYSPARKURI"
    sudo -E env "PATH=/usr/local/bin:$PATH" jupyter nbextension enable --py widgetsnbextension --system
    sudo mkdir -p /opt/jars/
    for url in $(echo $GEOPYSPARKJARS | tr , "\n")
    do
	if [[ $url == s3* ]]; then
	    (cd /opt/jars ; sudo aws s3 cp $url . )
	else
	    (cd /opt/jars ; sudo curl -L -O -C - $url )
	fi
    done

    # Install GeoPySpark + GeoNotebook kernel
    cat <<EOF > /tmp/kernel.json
{
    "language": "python",
    "display_name": "GeoPySpark",
    "argv": [
        "/usr/bin/python3.4",
        "-m",
        "ipykernel",
        "-f",
        "{connection_file}"
    ],
    "env": {
        "PYSPARK_PYTHON": "/usr/bin/python3.4",
        "PYSPARK_DRIVER_PYTHON": "/usr/bin/python3.4",
        "SPARK_HOME": "/usr/lib/spark",
        "PYTHONPATH": "/usr/lib/spark/python/lib/pyspark.zip:/usr/lib/spark/python/lib/py4j-0.10.4-src.zip",
        "GEOPYSPARK_JARS_PATH": "/opt/jars",
        "YARN_CONF_DIR": "/etc/hadoop/conf",
        "PYSPARK_SUBMIT_ARGS": "--conf hadoop.yarn.timeline-service.enabled=false pyspark-shell"
    }
}
EOF
    sudo cp /tmp/kernel.json /usr/share/jupyter/kernels/geopyspark/kernel.json
    rm -f /tmp/kernel.json

    # Execute
    cd /tmp
    sudo -u hublauncher -E env "PATH=/usr/local/bin:$PATH" jupyterhub --JupyterHub.spawner_class=sudospawner.SudoSpawner --SudoSpawner.sudospawner_path=/usr/local/bin/sudospawner --Spawner.notebook_dir=/home/{username} -f /tmp/jupyterhub_config.py &

else
    # Download packages
    mkdir -p /tmp/blobs/
    aws s3 sync $RPM_URI /tmp/blobs/

    # Install packages
    (cd /tmp/blobs; sudo yum localinstall -y gdal213-lib-2.1.3-33.x86_64.rpm hdf5-1.8.20-33.x86_64.rpm netcdf-4.5.0-33.x86_64.rpm proj493-lib-4.9.3-33.x86_64.rpm)

    # Install Python packages
    sudo pip-3.4 install --upgrade pip
    sudo ln -s /usr/local/bin/pip3 /usr/bin/
    sudo ln -s /usr/local/bin/pip3.4 /usr/bin/
    (cd /tmp/blobs ; sudo pip3.4 install *.whl)

    # Install GeoPySpark
    if [[ $GEOPYSPARKURI == s3* ]]; then
	aws s3 cp $GEOPYSPARKURI /tmp/geopyspark.zip
	GEOPYSPARKURI=/tmp/geopyspark.zip
    fi
    sudo -E env "PATH=/usr/local/bin:$PATH" pip3.4 install "$GEOPYSPARKURI"

    # Linkage
    echo '/usr/local/lib' > /tmp/local.conf
    echo '/usr/local/lib64' >> /tmp/local.conf
    sudo cp /tmp/local.conf /etc/ld.so.conf.d/local.conf
    sudo ldconfig
    rm -f /tmp/local.conf
fi
