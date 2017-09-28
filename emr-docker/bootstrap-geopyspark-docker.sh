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

for i in "$@"
do
    case $i in
        --continue)
            CONTINUE=true
            shift
            ;;
        -i=*|--image=*)
            IMAGE="${i#*=}"
            shift
            ;;
        -e=*|--env=*)
            ENV_VARS+=("-e ${i#*=}")
            shift
            ;;
        *)
            ;;
    esac
done

### MAIN ####

# EMR bootstrap runs before HDFS or YARN are initilized
if [ ! $CONTINUE ]; then
    sudo yum -y install docker
    sudo usermod -aG docker hadoop
    sudo service docker start

    THIS_SCRIPT="$(realpath "${BASH_SOURCE[0]}")"
    TIMEOUT= is_master && TIMEOUT=3 || TIMEOUT=4
    echo "bash -x $THIS_SCRIPT --continue $ARGS > /tmp/bootstrap-geopyspark-docker.log" | at now + $TIMEOUT min
    exit 0 # Bail and let EMR finish initializing
fi

YARN_RM=$(xmllint --xpath "//property[name='yarn.resourcemanager.hostname']/value/text()"  /etc/hadoop/conf/yarn-site.xml)

DOCKER_ENV="-e USER=hadoop \
-e ZOOKEEPERS=$YARN_RM \
${ENV_VARS[@]} \
-v /etc/hadoop/conf:/etc/hadoop/conf \
-v /usr/lib/hadoop-hdfs/bin:/usr/lib/hadoop-hdfs/bin"

DOCKER_OPT="-d --net=host --restart=always --memory-swappiness=0"

if is_master ; then
    sudo docker run $DOCKER_OPT --name=geopyspark $DOCKER_ENV $IMAGE
fi
