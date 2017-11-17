#Apache Yarn 2.7.1 cluster Docker image with Ubuntu

# Build the image

If you'd like to try directly from the Dockerfile you can build the image as:

```
sudo docker build  -t yarn-cluster .
```


# Start an Apache Yarn namenode container

In order to use the Docker image you have just build or pulled use:

```
sudo docker run -i -t --name namenode -h namenode yarn-cluster /etc/bootstrap.sh -bash -namenode
```

You should now be able to access the Hadoop Admin UI at

http://<host>:8088/cluster

**Make sure that SELinux is disabled on the host. If you are using boot2docker you don't need to do anything.**

# Start an Apache Yarn datanode container

In order to add data nodes to the Apache Yarn cluster, use:

```
sudo docker run -i -t --link namenode:namenode --dns=namenode yarn-cluster /etc/bootstrap.sh -bash -datanode
```

Notice that dns hostname should be registered to hosts file on the host. Use Ip address of namenode if namenode not found error reported by the docker.

To start yarn node, run 

```
cd $HADOOP_PREFIX
sbin/start-yarn.sh

bin/yarn rmadmin -refreshNodes
bin/yarn node -list
```

add node names and Ip addresses to /etc/hosts and distribute each node.


You should now be able to access the HDFS Admin UI at

http://<host>:50070

**Make sure that SELinux is disabled on the host. If you are using boot2docker you don't need to do anything.**

## Testing

You can run one of the stock examples:

```
cd $HADOOP_PREFIX

# add input files
bin/hdfs dfs -mkdir -p /user/root
bin/hdfs dfs -put $HADOOP_PREFIX/etc/hadoop/ input

# run the mapreduce
bin/hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.1.jar grep input output 'dfs[a-z.]+'

# check the output
bin/hdfs dfs -cat output/*
```

You can run an yarn example:

```
bin/yarn jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.1.jar pi 16 1000
```


# Start Apache Yarn namenode and datanode container by using docker-compose

```
sudo docker-compose -f docker-compose up -d
```
