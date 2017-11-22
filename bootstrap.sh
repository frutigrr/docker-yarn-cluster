#!/bin/bash

: ${HADOOP_PREFIX:=/usr/local/hadoop}

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$HADOOP_PREFIX/lib/native"
export HADOOP_HOME=$HADOOP_PREFIX

$HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

rm /tmp/*.pid 1>/dev/null 2>&1 

# installing libraries if any - (resource urls added comma separated to the ACP system variable)
cd $HADOOP_PREFIX/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

service ssh start

if [[ $1 = "-init" ]]; then
  sed s/HOSTNAME/$HOSTNAME/ $HADOOP_PREFIX/etc/hadoop/core-site.xml.template > $HADOOP_PREFIX/etc/hadoop/core-site.xml
  shift
  #exit
fi


if [[ $1 = "-namenode" || $2 = "-namenode" ]]; then
  # altering the core-site configuration
  sed s/HOSTNAME/$HOSTNAME/ $HADOOP_PREFIX/etc/hadoop/core-site.xml.template > $HADOOP_PREFIX/etc/hadoop/core-site.xml

  $HADOOP_PREFIX/sbin/start-dfs.sh
  $HADOOP_PREFIX/sbin/start-yarn.sh
fi

if [[ $1 = "-datanode" || $2 = "-datanode" ]]; then
  NAMENODE=$3
  if [[ $3 = "-master" || $3 = "-manager" ]]; then NAMENODE=$4; fi
  if [[ $NAMENODE = "" ]]; then NAMENODE=namenode; fi
  sed s/HOSTNAME/$NAMENODE/ $HADOOP_PREFIX/etc/hadoop/core-site.xml.template > $HADOOP_PREFIX/etc/hadoop/core-site.xml

  $HADOOP_PREFIX/sbin/start-dfs.sh
fi

if [[ $1 = "-d" || $2 = "-d" ]]; then
  while true; do sleep 5000; done
fi

if [[ $1 = "-bash" || $2 = "-bash" ]]; then
  /bin/bash
fi
