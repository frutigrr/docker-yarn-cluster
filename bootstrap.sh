#!/bin/bash

: ${HADOOP_PREFIX:=/usr/local/hadoop}

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$HADOOP_PREFIX/lib/native"
export HADOOP_HOME=$HADOOP_PREFIX

$HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

rm /tmp/*.pid 1>/dev/null 2>&1 

# installing libraries if any - (resource urls added comma separated to the ACP system variable)
cd $HADOOP_PREFIX/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

service ssh start

. /etc/bootcmd.sh
