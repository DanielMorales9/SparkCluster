FROM tenentedan9/ubuntu_jdk-8
MAINTAINER DanielMorales9

USER root

RUN apt-get update && \
    apt-get install -y curl unzip nano screen tmux wget git openssh-server openssh-client python3-setuptools python3-pip && \
    pip3 install --upgrade setuptools pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /usr/incubator-toree


# http://blog.stuart.axelbrooke.com/python-3-on-spark-return-of-the-pythonhashseed
ENV PYTHONHASHSEED 0
ENV PYTHONIOENCODING UTF-8
ENV PIP_DISABLE_PIP_VERSION_CHECK 1

WORKDIR /usr

# HADOOP
ARG HADOOP_VERSION=2.7.5
ARG HADOOP_BINARY_ARCHIVE_NAME=hadoop-$HADOOP_VERSION
ARG HADOOP_BINARY_DOWNLOAD_URL=http://mirror.koddos.net/apache/hadoop/common/$HADOOP_BINARY_ARCHIVE_NAME/$HADOOP_BINARY_ARCHIVE_NAME.tar.gz

RUN wget -qO - $HADOOP_BINARY_DOWNLOAD_URL | tar -xz -C /usr/ && \
    ln -s $HADOOP_BINARY_ARCHIVE_NAME hadoop

ENV HADOOP_HOME=/usr/hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$JAVA_HOME/bin

RUN mkdir -p /usr/hdfs/namenode && \ 
    mkdir -p /usr/hdfs/datanode && \
    mkdir $HADOOP_HOME/logs

# HADOOP master slave configuration
COPY config/* /tmp/
RUN mkdir -p ~/.ssh/config &&\ 
    mv /tmp/ssh_config ~/.ssh/config && \
    mv /tmp/hadoop-env.sh $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    mv /tmp/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \ 
    mv /tmp/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml && \
    mv /tmp/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml && \
    mv /tmp/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    mv /tmp/slaves $HADOOP_HOME/etc/hadoop/slaves && \
    mv /tmp/entrypoint.sh ~/entrypoint.sh && \
    chmod +x $HADOOP_HOME/sbin/start-dfs.sh && \
    chmod +x $HADOOP_HOME/sbin/start-yarn.sh && \
    chmod +x ~/entrypoint.sh && \
    hdfs namenode -format && \
    chmod 600 /root/.ssh/config && \
    chown root:root /root/.ssh/config && \
    ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa && \
    cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys

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

WORKDIR /usr

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


# copy pre-built toree
COPY toree-0.2.0.dev1.tar.gz /usr/incubator-toree/
VOLUME /home/code
VOLUME /home/data

# Download, uncompress and move all the required packages and libraries to their corresponding directories in /usr/local/ folder.
RUN wget -qO - ${SCALA_BINARY_DOWNLOAD_URL} | tar -xz -C /usr/ && \
    wget -qO - ${SBT_BINARY_DOWNLOAD_URL} | tar -xz -C /usr/  && \
    ln -s ${SCALA_BINARY_ARCHIVE_NAME} scala && \
    cp $SPARK_HOME/conf/log4j.properties.template $SPARK_HOME/conf/log4j.properties && \
    pip3 install jupyter && \ 
    pip3 install ./incubator-toree/toree-0.2.0.dev1.tar.gz && \
    jupyter toree install --spark_home=$SPARK_HOME-$SPARK_VERSION --interpreters=Scala,PySpark,SparkR,SQL && \
    mkdir -p /home/code && \
    mkdir -p /home/data 

CMD ["sh", "-c", "~/entrypoint.sh"]
