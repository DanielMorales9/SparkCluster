#!/bin/sh
set -e

NAME=$(hostname)

if [ "$NAME" = "master" ]; then
  echo "Master starting"
  $SPARK_HOME/sbin/start-master.sh
else 
  echo "Worker starting"
  $SPARK_HOME/sbin/start-slave.sh spark://master:7077
fi

while true; do sleep 1000000; done



