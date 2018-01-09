#!/bin/sh
set -e

service ssh start

ssh-keyscan master,worker,0.0.0.0 > ~/.ssh/known_hosts

$HADOOP_HOME/sbin/start-dfs.sh
$HADOOP_HOME/sbin/start-yarn.sh

NAME=$(hostname)

if [ "$NAME" = "master" ]; then
  echo "Master starting"
  $SPARK_HOME/sbin/start-master.sh
else 
  echo "Worker starting"
  $SPARK_HOME/sbin/start-slave.sh spark://master:7077
fi

while true; do sleep 1000000; done



