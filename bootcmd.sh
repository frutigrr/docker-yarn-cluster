#!/bin/bash

if [[ $1 = "-init" ]]; then
  sed s/HOSTNAME/$HOSTNAME/ $HADOOP_PREFIX/etc/hadoop/core-site.xml.template > $HADOOP_PREFIX/etc/hadoop/core-site.xml
  shift
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
