FROM ubuntu:14.04

MAINTAINER Sebastian Schoenherr <sebastian.schoenherr@i-med.ac.at>

# Change to root dir
WORKDIR /

# Install some basic tools
RUN sudo apt-get update -y
RUN sudo apt-get install libgmp10 wget apt-transport-https software-properties-common -y

# Install Prerequistes
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
RUN echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
RUN sudo add-apt-repository ppa:webupd8team/java
RUN wget http://archive.cloudera.com/cdh5/one-click-install/trusty/amd64/cdh5-repository_1.0_all.deb -O cdh5-repository_1.0_all.deb
RUN sudo dpkg -i cdh5-repository_1.0_all.deb

RUN wget https://github.com/jgm/pandoc/releases/download/1.19.2.1/pandoc-1.19.2.1-1-amd64.deb -O pandoc-1.19.2.1-1-amd64.deb
RUN sudo dpkg -i pandoc-1.19.2.1-1-amd64.deb

# update packages 
RUN sudo apt-get update -y

# Install Java v7
RUN sudo apt-get install jsvc git maven binutils -y
RUN wget https://debian.opennms.org/dists/opennms-25/main/binary-all/oracle-java8-installer_8u131-1~webupd8~2_all.deb
RUN sudo dpkg -i oracle-java8-installer_8u131-1~webupd8~2_all.deb

# Install latest CDH5 MapReduce 1
RUN sudo apt-get install hadoop-0.20-conf-pseudo -y
RUN sudo -u hdfs hdfs namenode -format

# Add a hadoop user (Cloudgene) to execute jobs
RUN sudo useradd -ms /bin/bash cloudgene

# copy script to start HDFS and MapReduce
COPY conf/run-hadoop-initial.sh /usr/bin/run-hadoop-initial.sh
RUN sudo chmod +x /usr/bin/run-hadoop-initial.sh

# generate some HDFS directories at startup
COPY conf/init-hdfs.sh /usr/bin/init-hdfs.sh
RUN sudo chmod +x /usr/bin/init-hdfs.sh

# Use a template to calculate the amount of map and reduce tasks depending on amount of cores
COPY conf/mapred-site-template.xml /usr/bin/mapred-site-template.xml
COPY conf/adapt-mapred-config.sh /usr/bin/adapt-mapred-config.sh
RUN sudo chmod +x /usr/bin/adapt-mapred-config.sh


COPY conf/execute-wordcount.sh /usr/bin/execute-wordcount.sh
RUN sudo chmod +x /usr/bin/execute-wordcount.sh

#HDFS Ports
EXPOSE 50010 50020 50070 50075 50090

#MapReduce Ports
EXPOSE 50030 50050 50070
