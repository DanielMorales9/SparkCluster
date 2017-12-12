# SparkCluster

Docker configuration for spark cluster

## Table of contents

1. [Overview](#overview)
2. [Docker Swarm](#docker-swarm)
   1. [Usage](#usage)
   2. [Scaling](#scaling)
3. [Data & Code](#data-&-code)
4. [Jupyter Scala](#jupyter-scala)

## Overview
This Docker container contains a full Spark distribution with the following components:

* Hadoop 2.8.0 (including YARN)
* Oracle JDK 8
* Scala 2.12.2
* Spark 2.2.0

It also includes the [Jupyter Notebook](https://github.com/jupyter/notebook) along with scala integration [Jupyter Scala](https://github.com/jupyter-scala/jupyter-scala)

## Docker Swarm
A `docker-compose.yml` file is provided to run the spark-cluster in the [Docker Swarm](https://docs.docker.com/engine/swarm/) environment

### Usage
Run the following command to run the Stack provided with the `docker-compose.yml`. It contains a spark master service and a worker instance. 
```bash
docker stack deploy -c docker-compose.yml <stack-name>
```

Feel free to customize the `docker-compose.yml` file for your need.    
To stop the container 
```bash
docker stack rm <stack-name>
```

### Scaling
If you need more worker instances, consider to scale the number of instances by typing the following command:
```bash
docker service scale <stack-name>_worker=<num_of_task>
```

## Data & Code
If you need to inject data and code into the containers use `data` and `code` volumes respectively in `/home/data` and `/home/code`

## Jupyter Scala
[Jupyter Scala](https://github.com/jupyter-scala/jupyter-scala) notebook will be built and configured for running, to launch the notebook follow the following commands:
```bash
docker exec -it <stack-name>_master.<id> bash
jupyter notebook --allow-root
```



