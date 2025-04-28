#!/bin/bash
sudo service ssh start
ssh-keyscan -H m1 m2 m3 >> ~/.ssh/known_hosts
echo "${HOSTNAME: -1}" > /usr/local/zookeeper/myid

if [[ "$HOSTNAME" == *"m"* ]]; then
    hdfs --daemon start journalnode && /usr/local/zookeeper/bin/zkServer.sh start
    sleep 3

    if [[ "$HOSTNAME" == "m1" ]]; then
        if [[ ! -d "/usr/local/hadoop/hdfs/namenode/current" ]]; then
            hdfs namenode -format -clusterId hadoop-cluster && hdfs zkfc -formatZK
        fi
        hdfs --daemon start namenode && hdfs --daemon start zkfc
        yarn --daemon start resourcemanager

    else
        if [[ ! -d "/usr/local/hadoop/hdfs/namenode/current" ]]; then
            sleep 5
            hdfs namenode -bootstrapStandby
        fi
        hdfs --daemon start namenode && hdfs --daemon start zkfc
        yarn --daemon start resourcemanager
    fi
elif [[ "$HOSTNAME" == *"s"* ]]; then
    hdfs --daemon start datanode && yarn --daemon start nodemanager

elif [[ "$HOSTNAME" == "h1" ]]; then
    if hdfs dfs -test -f /apps/tez/_init_done.flag;  then
        hdfs dfs -mkdir -p /user/hive/warehouse
        hdfs dfs -mkdir -p /tmp
        hdfs dfs -chmod -R 777 /tmp
        hdfs dfs -chmod -R 777 /user/hive/warehouse
        hdfs dfs -mkdir -p /apps/tez
        hdfs dfs -chmod -R 777 /apps/tez
        hdfs dfs -put /usr/local/tez/share/tez.tar.gz /apps/tez/
        hdfs dfs -chmod 777 /apps/tez/tez.tar.gz

        $HIVE_HOME/bin/schematool -initSchema -dbType postgres 
    fi
    hive --service metastore &

elif [[ "$HOSTNAME" == "h2" ]]; then
    sleep 60
    hiveserver2 &
fi

tail -f /dev/null


# beeline -u "jdbc:hive2://localhost:10000"
# SET hive.execution.engine=tez;
# USE test_db;
# CREATE TABLE test_table (id INT, name STRING);
INSERT INTO test_table VALUES
  (1, 'Alice'),
  (2, 'Bob');
#   (3, 'Charlie'),
#   (4, 'Diana'),
#   (5, 'Ethan'),
#   (6, 'Fatima'),
#   (7, 'George'),
#   (8, 'Hana'),
#   (9, 'Ibrahim'),
#   (10, 'Julia'),
#   (11, 'Khaled'),
#   (12, 'Lina'),
#   (13, 'Mark'),
#   (14, 'Nora'),
#   (15, 'Omar'),
#   (16, 'Pia'),
#   (17, 'Qasim'),
#   (18, 'Rania'),
#   (19, 'Salim'),
#   (20, 'Tala');

