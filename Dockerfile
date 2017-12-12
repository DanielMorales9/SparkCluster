FROM gettyimages/spark
MAINTAINER DanielMorales9

# Scala related variables.
ARG SCALA_VERSION=2.12.2
ARG SCALA_BINARY_ARCHIVE_NAME=scala-${SCALA_VERSION}
ARG SCALA_BINARY_DOWNLOAD_URL=http://downloads.lightbend.com/scala/${SCALA_VERSION}/${SCALA_BINARY_ARCHIVE_NAME}.tgz

# SBT related variables.
ARG SBT_VERSION=0.13.15
ARG SBT_BINARY_ARCHIVE_NAME=sbt-$SBT_VERSION
ARG SBT_BINARY_DOWNLOAD_URL=https://dl.bintray.com/sbt/native-packages/sbt/${SBT_VERSION}/${SBT_BINARY_ARCHIVE_NAME}.tgz

#Jupyter scala
ARG JUPYTER_BINARY_DOWNLOAD=https://github.com/alexarchambault/jupyter-scala.git

# Configure env variables for Scala, SBT and Spark.
# Also configure PATH env variable to include binary folders of Java, Scala, SBT and Spark.
ENV SCALA_HOME  /usr/scala
ENV SBT_HOME    /usr/sbt
ENV JUP_HOME	/usr/jupyter-scala
ENV PATH        $PATH:$JAVA_HOME/bin:$SCALA_HOME/bin:$SBT_HOME/bin

WORKDIR /usr
# Download, uncompress and move all the required packages and libraries to their corresponding directories in /usr/local/ folder.
RUN apt-get -y update && \
    apt-get install -y vim screen tmux wget git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    wget -qO - ${SCALA_BINARY_DOWNLOAD_URL} | tar -xz -C /usr/ && \
    wget -qO - ${SBT_BINARY_DOWNLOAD_URL} | tar -xz -C /usr/  && \
    git clone $JUPYTER_BINARY_DOWNLOAD && \
    pip install jupyter && \ 
    cd jupyter-scala && \
    sbt publishLocal && \
    ./jupyter-scala --id scala-develop --name "Scala" --force && \
    cd /usr/ && \
    ln -s ${SCALA_BINARY_ARCHIVE_NAME} scala && \
    cp $SPARK_HOME/conf/log4j.properties.template $SPARK_HOME/conf/log4j.properties && \
    sed -i -e s/WARN/ERROR/g $SPARK_HOME/conf/log4j.properties && \
    sed -i -e s/INFO/ERROR/g $SPARK_HOME/conf/log4j.properties && \
    ln -s ${SPARK_HOME} spark 

EXPOSE 8888
WORKDIR $SPARK_HOME
#CMD ["/bin/bash"]
CMD ["bin/spark-class", "org.apache.spark.deploy.master.Master"]
