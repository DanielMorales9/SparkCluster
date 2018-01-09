#!/bin/sh
set -e

service ssh start

ssh-keyscan namenode,datanode,0.0.0.0 > ~/.ssh/known_hosts

$HADOOP_HOME/sbin/start-dfs.sh
$HADOOP_HOME/sbin/start-yarn.sh

while true; do sleep 1000000; done



