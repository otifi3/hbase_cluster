FROM ubuntu:22.04 AS hadoop

ENV HADOOP_HOME=/usr/local/hadoop
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin


RUN apt update && \
    apt install -y sudo openjdk-8-jdk ssh && \
    apt clean

RUN useradd -m -s /bin/bash hadoop && \
    echo "hadoop ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers


WORKDIR /usr/local

# Download and extract Hadoop   
ADD https://downloads.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz ./
RUN tar -xvzf hadoop-3.3.6.tar.gz \
    && mv hadoop-3.3.6 $HADOOP_HOME \
    && rm hadoop-3.3.6.tar.gz \
    && chown -R hadoop:hadoop $HADOOP_HOME 

ADD https://downloads.apache.org/zookeeper/zookeeper-3.9.3/apache-zookeeper-3.9.3-bin.tar.gz ./
RUN tar -xvzf apache-zookeeper-3.9.3-bin.tar.gz \
    && mv apache-zookeeper-3.9.3-bin /usr/local/zookeeper \
    && rm apache-zookeeper-3.9.3-bin.tar.gz \
    && chown -R hadoop:hadoop /usr/local/zookeeper

RUN mkdir -p $HADOOP_HOME/hdfs/namenode $HADOOP_HOME/hdfs/datanode $HADOOP_HOME/journal $HADOOP_HOME/logs && \
    chown -R hadoop:hadoop $HADOOP_HOME/hdfs $HADOOP_HOME/journal $HADOOP_HOME/logs

COPY configs/*.xml $HADOOP_HOME/etc/hadoop/
COPY configs/workers $HADOOP_HOME/etc/hadoop/
COPY configs/zoo.cfg /usr/local/zookeeper/conf/
COPY ./entrypoint.sh /home/hadoop/
COPY ./health_check.sh /home/hadoop/

RUN chmod +x /home/hadoop/entrypoint.sh && \
    chown hadoop:hadoop /home/hadoop/entrypoint.sh && \
    chmod +x /home/hadoop/health_check.sh && \
    chown hadoop:hadoop /home/hadoop/health_check.sh 


WORKDIR /home/hadoop

# Switch to non-root user
USER hadoop

# Set up SSH for passwordless login
RUN mkdir -p /home/hadoop/.ssh && ssh-keygen -t rsa -f /home/hadoop/.ssh/id_rsa -N "" 
RUN cat /home/hadoop/.ssh/id_rsa.pub >> /home/hadoop/.ssh/authorized_keys

EXPOSE 9870 8088

ENTRYPOINT ["/home/hadoop/entrypoint.sh"]


FROM hadoop AS hive

USER root

ENV HIVE_HOME=/usr/local/hive
ENV PATH=$HADOOP_HOME/bin:$HIVE_HOME/bin:$PATH
ENV PATH=$PATH:$HADOOP_HOME/bin:$HIVE_HOME/bin
ENV TEZ_HOME=/usr/local/tez
ENV TEZ_CONF_DIR=$TEZ_HOME/conf
ENV HIVE_AUX_JARS_PATH=$TEZ_HOME

ADD https://downloads.apache.org/hive/hive-4.0.1/apache-hive-4.0.1-bin.tar.gz ./
RUN tar -xvzf apache-hive-4.0.1-bin.tar.gz \
    && mv apache-hive-4.0.1-bin /usr/local/hive \
    && rm apache-hive-4.0.1-bin.tar.gz \
    && chown -R hadoop:hadoop /usr/local/hive


ADD https://archive.apache.org/dist/tez/0.10.3/apache-tez-0.10.3-bin.tar.gz  ./
RUN tar -xvzf apache-tez-0.10.3-bin.tar.gz \
    && mv apache-tez-0.10.3-bin /usr/local/tez \
    && rm apache-tez-0.10.3-bin.tar.gz  \
    && chown -R hadoop:hadoop /usr/local/tez

ADD https://jdbc.postgresql.org/download/postgresql-42.2.5.jar ./
RUN mv ./postgresql-42.2.5.jar $HIVE_HOME/lib/ && \
    chown -R hadoop:hadoop $HIVE_HOME/lib/postgresql-42.2.5.jar

COPY ./hive_configs/hive-site.xml $HIVE_HOME/conf/
COPY ./hive_configs/tez-site.xml $TEZ_HOME/conf/

EXPOSE 10000

WORKDIR /home/hadoop

USER hadoop

ENTRYPOINT ["/home/hadoop/entrypoint.sh"]
