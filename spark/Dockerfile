#FROM frutigrr/yarn-cluster:latest
FROM yarn-cluster:latest
MAINTAINER frutigrr

#install R
RUN apt-get update && \
    apt-get install -y r-base python python-dev python-pip libssl-dev git make locate vim && \
    apt-get autoremove -y && \
    apt-get clean && \
    /usr/bin/updatedb

#support for Hadoop 2.7
#ENV SPARK_DOWNLOAD_URL http://archive.apache.org/dist/spark/spark-2.2.0/spark-2.2.0-bin-hadoop2.7.tgz
#ENV SPARK_DOWNLOAD_URL http://ftp.kddilabs.jp/infosystems/apache/spark/spark-2.2.0/spark-2.2.0-bin-hadoop2.7.tgz
ENV SPARK_DOWNLOAD_URL http://ftp.jaist.ac.jp/pub/apache/spark/spark-2.2.0/spark-2.2.0-bin-hadoop2.7.tgz
RUN curl -s $SPARK_DOWNLOAD_URL | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s spark-2.2.0-bin-hadoop2.7 spark
ENV SPARK_HOME /usr/local/spark
RUN mkdir $SPARK_HOME/yarn-remote-client
ADD yarn-remote-client $SPARK_HOME/yarn-remote-client
COPY yarn-remote-client/core-site.xml.spark.template $HADOOP_PREFIX/etc/hadoop/
COPY yarn-remote-client/yarn-site.xml.spark.template $HADOOP_PREFIX/etc/hadoop/
COPY log4j.properties $SPARK_HOME/conf/log4j.properties


RUN $BOOTSTRAP -namenode && \
    $HADOOP_PREFIX/bin/hdfs dfsadmin -safemode leave && \
    $HADOOP_PREFIX/bin/hdfs dfs -mkdir -p /tmp/logs && \
    $HADOOP_PREFIX/bin/hdfs dfs -chmod -R 1777 /tmp && \
    $HADOOP_PREFIX/bin/hdfs dfs -put $SPARK_HOME-2.2.0-bin-hadoop2.7/jars /spark

ENV YARN_CONF_DIR $HADOOP_PREFIX/etc/hadoop
ENV PATH $PATH:$SPARK_HOME/bin:$HADOOP_PREFIX/bin
# update boot script
COPY bootstrap.sh /etc/bootstrap.sh
COPY yarn-remote-client/bootcmd.sh /etc/bootcmd.sh
RUN chown root.root /etc/bootstrap.sh /etc/bootcmd.sh
RUN chmod 700 /etc/bootstrap.sh /etc/bootcmd.sh

CMD ["/etc/bootstrap.sh", "-d"]

EXPOSE 8088 8042 4040

