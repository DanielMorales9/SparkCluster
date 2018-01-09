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

VOLUME /home/code
VOLUME /home/data

# Download, uncompress and move all the required packages and libraries to their corresponding directories in /usr/local/ folder.
RUN mkdir -p /home/code && \
    mkdir -p /home/data 

CMD ["sh", "-c", "~/entrypoint.sh"]
