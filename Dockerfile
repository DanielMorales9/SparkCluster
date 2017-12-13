FROM debian:jessie
MAINTAINER DanielMorales9

RUN apt-get update \
 && apt-get install -y locales \
 && dpkg-reconfigure -f noninteractive locales \
 && locale-gen C.UTF-8 \
 && /usr/sbin/update-locale LANG=C.UTF-8 \
 && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
 && locale-gen \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Users with other locales should set this in their derivative image
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN apt-get update && \
    apt-get install -y curl unzip nano screen tmux wget git \
    python3 python3-setuptools && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    easy_install3 pip py4j && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /usr/incubator-toree

# http://blog.stuart.axelbrooke.com/python-3-on-spark-return-of-the-pythonhashseed
ENV PYTHONHASHSEED 0
ENV PYTHONIOENCODING UTF-8
ENV PIP_DISABLE_PIP_VERSION_CHECK 1

# JAVA
ARG JAVA_MAJOR_VERSION=8
ARG JAVA_UPDATE_VERSION=131
ARG JAVA_BUILD_NUMBER=11
ENV JAVA_HOME /usr/jdk1.${JAVA_MAJOR_VERSION}.0_${JAVA_UPDATE_VERSION}

RUN curl -sL --retry 3 --insecure \
  --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
  "http://download.oracle.com/otn-pub/java/jdk/${JAVA_MAJOR_VERSION}u${JAVA_UPDATE_VERSION}-b${JAVA_BUILD_NUMBER}/d54c1d3a095b4ff2b6607d096fa80163/server-jre-${JAVA_MAJOR_VERSION}u${JAVA_UPDATE_VERSION}-linux-x64.tar.gz" \
  | gunzip \
  | tar x -C /usr/ \
  && ln -s $JAVA_HOME /usr/java \
  && rm -rf $JAVA_HOME/man

# SPARK
ARG HADOOP_VERSION=2.7
ARG SPARK_VERSION=2.2.1
ARG SPARK_BINARY_ARCHIVE_NAME=spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}
ARG SPARK_BINARY_DOWNLOAD_URL=https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/$SPARK_BINARY_ARCHIVE_NAME.tgz
ENV SPARK_HOME /usr/spark
RUN wget -qO - ${SPARK_BINARY_DOWNLOAD_URL} | tar -xz -C /usr/ && \
    mv /usr/$SPARK_BINARY_ARCHIVE_NAME $SPARK_HOME-${SPARK_VERSION} && \
    chown -R root:root $SPARK_HOME-${SPARK_VERSION} && \
    ln -s ${SPARK_HOME}-${SPARK_VERSION} ${SPARK_HOME}


# Scala related variables.
ARG SCALA_VERSION=2.11.12
ARG SCALA_BINARY_ARCHIVE_NAME=scala-${SCALA_VERSION}
ARG SCALA_BINARY_DOWNLOAD_URL=http://downloads.lightbend.com/scala/${SCALA_VERSION}/${SCALA_BINARY_ARCHIVE_NAME}.tgz

# SBT related variables.
ARG SBT_VERSION=0.13.15
ARG SBT_BINARY_ARCHIVE_NAME=sbt-$SBT_VERSION
ARG SBT_BINARY_DOWNLOAD_URL=https://dl.bintray.com/sbt/native-packages/sbt/${SBT_VERSION}/${SBT_BINARY_ARCHIVE_NAME}.tgz

# Configure env variables for Scala, SBT and Spark.
# Also configure PATH env variable to include binary folders of Java, Scala, SBT and Spark.
ENV SCALA_HOME  /usr/scala
ENV SBT_HOME    /usr/sbt
ENV PATH        $PATH:$JAVA_HOME/bin:$SCALA_HOME/bin:$SBT_HOME/bin:$JAVA_HOME/bin:$SPARK_HOME/bin

WORKDIR /usr

# copy pre-built toree
COPY toree-0.2.0.dev1.tar.gz /usr/incubator-toree/
VOLUME /home/code
VOLUME /home/data

# Download, uncompress and move all the required packages and libraries to their corresponding directories in /usr/local/ folder.
RUN wget -qO - ${SCALA_BINARY_DOWNLOAD_URL} | tar -xz -C /usr/ && \
    wget -qO - ${SBT_BINARY_DOWNLOAD_URL} | tar -xz -C /usr/  && \
    ln -s ${SCALA_BINARY_ARCHIVE_NAME} scala && \
    cp $SPARK_HOME/conf/log4j.properties.template $SPARK_HOME/conf/log4j.properties && \
    sed -i -e s/WARN/ERROR/g $SPARK_HOME/conf/log4j.properties && \
    sed -i -e s/INFO/ERROR/g $SPARK_HOME/conf/log4j.properties && \
    pip install jupyter && \ 
    pip install ./incubator-toree/toree-0.2.0.dev1.tar.gz && \
    jupyter toree install --spark_home=$SPARK_HOME-$SPARK_VERSION --interpreters=Scala,PySpark,SparkR,SQL && \
    mkdir -p /home/code && \
    mkdir -p /home/data 

WORKDIR $SPARK_HOME

CMD ["bin/spark-class", "org.apache.spark.deploy.master.Master"]
