# SparkCluster

Docker configuration for spark cluster

## Table of contents

1. [Overview](#overview)
2. [Docker Swarm](#docker-swarm)
   1. [Usage](#usage)
      1. [Multi-Host Swarm](#multi-host-swarm)
   2. [Scaling](#scaling)
3. [Data & Code](#data-&-code)
4. [Toree](#toree)
5. [TODOs](#todos)

## Overview
This Docker container contains a full Spark distribution with the following components:

* Oracle JDK 8
* Hadoop 2.7.5
* Scala 2.11.12
* Spark 2.2.1

It also includes the [Apache Toree](https://github.com/apache/incubator-toree) installation.
## Docker Swarm
A `docker-compose.yml` file is provided to run the spark-cluster in the [Docker Swarm](https://docs.docker.com/engine/swarm/) environment

### Usage
Type the following commands to run the stack provided with the `docker-compose.yml`. It contains a spark master service and a worker instance. 
```bash
docker network create -d overlay --attachable --scope swarm core  
docker stack deploy -c docker-compose.yml <stack-name>
```

#### Multi-host swarm
To run the stack in cluster mode, create the swarm before creating the overlay network.   
Otherwise the stack will deployed in a single swarm node --- the manager. 

To stop the container type:
```bash
docker stack rm <stack-name>
```

### Scaling
If you need more worker instances, consider to scale the number of instances by typing the following command:
```bash
docker service scale <stack-name>_worker=<num_of_task>
```

## Data & Code
If you need to inject data and code into the containers use `data` and `code` volumes respectively in `/home/data` and `/home/code`.

## Toree
Apache Toree notebook is already built, to launch a spark notebook follow the following commands:
```bash
docker exec -it <stack-name>_master.<id> bash
SPARK_OPTS='--master=spark://master:7077' jupyter notebook --ip 0.0.0.0 --allow-root
```

The last command allows the notebook to execute jobs in cluster mode rather than in local mode. 

Apache Toree includes SparkR, PySpark, Spark Scala and SQL. 


## TODOs
* Separating Jupyter notebook into a different  

