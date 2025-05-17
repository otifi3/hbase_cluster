#!/bin/bash

# Start SSH
sudo service ssh start

# Add internal cluster nodes to known_hosts
ssh-keyscan -H m1 m2 zk1 zk2 zk3 s1 s2 >> ~/.ssh/known_hosts

# Dynamically set ZooKeeper myid (e.g., zk1 → 1)
MYID=$(echo "$HOSTNAME" | grep -o '[0-9]\+$')
if [[ -n "$MYID" ]]; then
    echo "$MYID" > /usr/local/zookeeper/myid
fi

# If the node is zk1, zk2, or zk3 — start ZK + JournalNode
if [[ "$HOSTNAME" == zk* ]]; then
    /usr/local/zookeeper/bin/zkServer.sh start
    hdfs --daemon start journalnode

# Master/Standby NameNodes (m1, m2, ...)
elif [[ "$HOSTNAME" == m* ]]; then

    if [[ "$HOSTNAME" == "m1" ]]; then
        if [[ ! -d "/usr/local/hadoop/hdfs/namenode/current" ]]; then
            hdfs namenode -format -clusterId hadoop-cluster && hdfs zkfc -formatZK
        fi
        hdfs --daemon start namenode
        hdfs --daemon start zkfc
        yarn --daemon start resourcemanager

    else  # m2 or any other standby
        if [[ ! -d "/usr/local/hadoop/hdfs/namenode/current" ]]; then
            sleep 5
            hdfs namenode -bootstrapStandby
        fi
        hdfs --daemon start namenode
        hdfs --daemon start zkfc
        yarn --daemon start resourcemanager
    fi

# DataNodes (s1, s2, ...)
elif [[ "$HOSTNAME" == s* ]]; then
    hdfs --daemon start datanode
    yarn --daemon start nodemanager
fi

# Keep container running
tail -f /dev/null
