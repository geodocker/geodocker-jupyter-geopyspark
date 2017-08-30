#!/usr/bin/env bash

OLD_ADDR=ip-172-31-50-173

if [[ ! -z $NEW_ADDR ]]; then
    sed "s,$OLD_ADDR,$NEW_ADDR,g" /etc/hadoop/conf/core-site.xml -i
    sed "s,$OLD_ADDR,$NEW_ADDR,g" /etc/hadoop/conf/yarn-site.xml -i
else
    rm -f /etc/hadoop/conf/*.xml
fi

jupyterhub --no-ssl --Spawner.notebook_dir=/home/hadoop/notebooks
