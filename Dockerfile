# Creates pseudo distributed hadoop 2.7.1
#
# sudo docker build -t yarn_cluster .

FROM ubuntu:16.04
MAINTAINER frutigrr

USER root

# install dev tools
RUN apt-get update && \
    apt-get install -y curl tar sudo openssh-server openssh-client rsync locate && \
    apt-get autoremove -y && \
    apt-get clean && \
    /usr/bin/updatedb

# update libselinux. see https://github.com/sequenceiq/hadoop-docker/issues/14
#RUN yum update -y libselinux

# passwordless ssh
RUN rm -f /etc/ssh/ssh_host_dsa_key /etc/ssh/ssh_host_rsa_key /root/.ssh/id_rsa
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa
RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys

# install java
ENV JAVA_VER 8u151
ENV JAVA_BUILD b12
ENV JAVA_VER_BUILD $JAVA_VER-$JAVA_BUILD
ENV JAVA_URL_KEY /e758a0de34e24606bca991d704f6dcbf
RUN mkdir -p /usr/java/default && \
    curl -Ls "http://download.oracle.com/otn-pub/java/jdk/${JAVA_VER_BUILD}${JAVA_URL_KEY}/jdk-${JAVA_VER}-linux-x64.tar.gz" -H 'Cookie: gpw_e24=xxx; oraclelicense=accept-securebackup-cookie;' | \
    tar --strip-components=1 -xz -C /usr/java/default/

ENV JAVA_HOME /usr/java/default
ENV PATH $PATH:$JAVA_HOME/bin

# install hadoop
# need to build the native library to change version 
COPY archives/hadoop-2.7.1.tar.gz /tmp
RUN tar -xzf /tmp/hadoop-2.7.1.tar.gz -C /usr/local/  || true
RUN if [ ! -d /usr/local/hadoop-2.7.1 ]; then curl -s http://archive.apache.org/dist/hadoop/common/hadoop-2.7.1/hadoop-2.7.1.tar.gz | tar -xz -C /usr/local/ ; fi
RUN cd /usr/local && ln -s ./hadoop-2.7.1 hadoop

ENV HADOOP_PREFIX /usr/local/hadoop
ENV HADOOP_COMMON_HOME /usr/local/hadoop
ENV HADOOP_HDFS_HOME /usr/local/hadoop
ENV HADOOP_MAPRED_HOME /usr/local/hadoop
ENV HADOOP_YARN_HOME /usr/local/hadoop
ENV HADOOP_CONF_DIR /usr/local/hadoop/etc/hadoop
ENV YARN_CONF_DIR $HADOOP_PREFIX/etc/hadoop

RUN sed -i '/^export JAVA_HOME/ s:.*:export JAVA_HOME=/usr/java/default\nexport HADOOP_PREFIX=/usr/local/hadoop\nexport HADOOP_HOME=/usr/local/hadoop\n:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh
RUN sed -i '/^export HADOOP_CONF_DIR/ s:.*:export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

RUN mkdir -p $HADOOP_PREFIX/input
RUN cp $HADOOP_PREFIX/etc/hadoop/*.xml $HADOOP_PREFIX/input
RUN cp -r $HADOOP_PREFIX/etc/hadoop $HADOOP_PREFIX/etc/original

# pseudo distributed
ADD etc/hadoop/core-site.xml.template $HADOOP_PREFIX/etc/hadoop/core-site.xml.template
#RUN sed s/HOSTNAME/localhost/ /usr/local/hadoop/etc/hadoop/core-site.xml.template > /usr/local/hadoop/etc/hadoop/core-site.xml
ADD etc/hadoop/hdfs-site.xml $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml

ADD etc/hadoop/mapred-site.xml $HADOOP_PREFIX/etc/hadoop/mapred-site.xml
ADD etc/hadoop/yarn-site.xml $HADOOP_PREFIX/etc/hadoop/yarn-site.xml

# format HDFS
RUN $HADOOP_PREFIX/bin/hdfs namenode -format

# fixing the libhadoop.so like a boss
RUN rm  /usr/local/hadoop/lib/native/*
RUN curl -Ls http://github.com/sequenceiq/docker-hadoop-build/releases/download/v2.7.1/hadoop-native-64-2.7.1.tgz  | tar -xz -C /usr/local/hadoop/lib/native/
RUN echo /usr/local/hadoop/lib/native > /etc/ld.so.conf.d/hadoop.conf

ADD ssh_config /root/.ssh/config
RUN chmod 600 /root/.ssh/config
RUN chown root:root /root/.ssh/config

ADD bootstrap.sh /etc/bootstrap.sh
ADD bootcmd.sh /etc/bootcmd.sh
RUN chown root:root /etc/bootstrap.sh /etc/bootcmd.sh
RUN chmod 700 /etc/bootstrap.sh /etc/bootcmd.sh

ENV BOOTSTRAP /etc/bootstrap.sh

# workingaround docker.io build error
RUN ls -la /usr/local/hadoop/etc/hadoop/*-env.sh
RUN chmod +x /usr/local/hadoop/etc/hadoop/*-env.sh
RUN ls -la /usr/local/hadoop/etc/hadoop/*-env.sh

# fix the 254 error code
RUN sed  -i "/^[^#]*UsePAM/ s/.*/#&/"  /etc/ssh/sshd_config
RUN echo "UsePAM no" >> /etc/ssh/sshd_config
RUN echo "Port 2122" >> /etc/ssh/sshd_config

# install debug tools
RUN apt-get update && \
    apt-get install -y vim less lsof iproute2 iputils-ping && \
    apt-get autoremove -y && \
    apt-get clean && \
    /usr/bin/updatedb

# enable ssh
RUN systemctl enable ssh

CMD ["/etc/bootstrap.sh", "-d"]

# Hdfs ports
EXPOSE 50010 50020 50070 50075 50090
# Mapred ports
EXPOSE 19888
#Yarn ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088
#Other ports
EXPOSE 49707 2122 

