############################
# Stage 1: hadoop-base
############################
FROM ubuntu:22.04 AS hadoop-base

ENV HADOOP_HOME=/usr/local/hadoop
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

RUN apt update && \
    apt install -y sudo openjdk-8-jdk ssh curl tar && \
    apt clean

# Create user
RUN useradd -m -s /bin/bash hadoop && \
    echo "hadoop ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Download Hadoop
WORKDIR /usr/local
ADD https://downloads.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz ./
RUN tar -xvzf hadoop-3.3.6.tar.gz && \
    mv hadoop-3.3.6 $HADOOP_HOME && \
    rm hadoop-3.3.6.tar.gz && \
    chown -R hadoop:hadoop $HADOOP_HOME

# Create common folders
RUN mkdir -p $HADOOP_HOME/hdfs/namenode $HADOOP_HOME/hdfs/datanode $HADOOP_HOME/journal $HADOOP_HOME/logs && \
    chown -R hadoop:hadoop $HADOOP_HOME/hdfs $HADOOP_HOME/journal $HADOOP_HOME/logs

# SSH setup for Hadoop user
USER hadoop
RUN mkdir -p /home/hadoop/.ssh && \
    ssh-keygen -t rsa -f /home/hadoop/.ssh/id_rsa -N "" && \
    cat /home/hadoop/.ssh/id_rsa.pub >> /home/hadoop/.ssh/authorized_keys

############################
# Stage 2: ZooKeeper node
############################
FROM hadoop-base AS zookeeper-node

USER root
WORKDIR /usr/local
ADD https://downloads.apache.org/zookeeper/zookeeper-3.9.3/apache-zookeeper-3.9.3-bin.tar.gz ./
RUN tar -xvzf apache-zookeeper-3.9.3-bin.tar.gz && \
    mv apache-zookeeper-3.9.3-bin /usr/local/zookeeper && \
    rm apache-zookeeper-3.9.3-bin.tar.gz && \
    chown -R hadoop:hadoop /usr/local/zookeeper

# Copy ZooKeeper config
COPY configs/zoo.cfg /usr/local/zookeeper/conf/

USER hadoop
WORKDIR /home/hadoop
COPY ./entrypoint.sh /home/hadoop/
RUN chmod +x entrypoint.sh

EXPOSE 2181 2888 3888
ENTRYPOINT ["/home/hadoop/entrypoint.sh"]

############################
# Stage 3: NameNode container
############################
FROM hadoop-base AS namenode

USER root
COPY configs/*.xml $HADOOP_HOME/etc/hadoop/
COPY configs/workers $HADOOP_HOME/etc/hadoop/
COPY ./entrypoint.sh /home/hadoop/
RUN chmod +x /home/hadoop/entrypoint.sh && chown hadoop:hadoop /home/hadoop/entrypoint.sh

USER hadoop
WORKDIR /home/hadoop
EXPOSE 9870 8020 8485
ENTRYPOINT ["/home/hadoop/entrypoint.sh"]

############################
# Stage 4: DataNode container
############################
FROM hadoop-base AS datanode

USER root
COPY configs/*.xml $HADOOP_HOME/etc/hadoop/
COPY configs/workers $HADOOP_HOME/etc/hadoop/
COPY ./entrypoint.sh /home/hadoop/
RUN chmod +x /home/hadoop/entrypoint.sh && chown hadoop:hadoop /home/hadoop/entrypoint.sh

USER hadoop
WORKDIR /home/hadoop
EXPOSE 9864
ENTRYPOINT ["/home/hadoop/entrypoint.sh"]

############################
# Stage 5: Hive container 
############################
FROM hadoop-base AS hive

USER root

ENV HIVE_HOME=/usr/local/hive
ENV TEZ_HOME=/usr/local/tez
ENV TEZ_CONF_DIR=$TEZ_HOME/conf
ENV HIVE_AUX_JARS_PATH=$TEZ_HOME
ENV PATH=$HIVE_HOME/bin:$TEZ_HOME/bin:$PATH

# Hive
ADD https://downloads.apache.org/hive/hive-4.0.1/apache-hive-4.0.1-bin.tar.gz ./
RUN tar -xvzf apache-hive-4.0.1-bin.tar.gz && \
    mv apache-hive-4.0.1-bin /usr/local/hive && \
    rm apache-hive-4.0.1-bin.tar.gz && \
    chown -R hadoop:hadoop /usr/local/hive

# Tez
ADD https://archive.apache.org/dist/tez/0.10.3/apache-tez-0.10.3-bin.tar.gz ./
RUN tar -xvzf apache-tez-0.10.3-bin.tar.gz && \
    mv apache-tez-0.10.3-bin /usr/local/tez && \
    rm apache-tez-0.10.3-bin.tar.gz && \
    chown -R hadoop:hadoop /usr/local/tez

# Postgres JDBC
ADD https://jdbc.postgresql.org/download/postgresql-42.2.5.jar ./
RUN mv postgresql-42.2.5.jar $HIVE_HOME/lib/

# Hive configs
COPY hive_configs/hive-site.xml $HIVE_HOME/conf/
COPY hive_configs/tez-site.xml $TEZ_HOME/conf/

USER hadoop
WORKDIR /home/hadoop
COPY ./entrypoint.sh .
RUN chmod +x entrypoint.sh

EXPOSE 10000
ENTRYPOINT ["/home/hadoop/entrypoint.sh"]
