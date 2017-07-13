#!/usr/bin/env bash

IMAGE=quay.io/geodocker/jupyter-geopyspark:${TAG:-"latest"}

# Parses a configuration file put in place by EMR to determine the role of this node
is_master() {
  if [ $(jq '.isMaster' /mnt/var/lib/info/instance.json) = 'true' ]; then
    return 0
  else
    return 1
  fi
}

### MAIN ####

THIS_SCRIPT="$(realpath "${BASH_SOURCE[0]}")"

sudo yum -y install docker
sudo usermod -aG docker hadoop
sudo service docker start

YARN_RM=$(xmllint --xpath "//property[name='yarn.resourcemanager.hostname']/value/text()"  /etc/hadoop/conf/yarn-site.xml)

DOCKER_ENV="-e USER=hadoop \
-e ZOOKEEPERS=$YARN_RM \
${ENV_VARS[@]} \
-v /etc/hadoop/conf:/yarn \
-v /etc/hadoop/conf:/etc/hadoop/conf \
-v /usr/lib/hadoop-hdfs/bin:/usr/lib/hadoop-hdfs/bin"

DOCKER_OPT="-d --net=host --restart=always --memory-swappiness=0"

if is_master ; then
    sudo docker run $DOCKER_OPT --name=geopyspark $DOCKER_ENV $IMAGE
fi
