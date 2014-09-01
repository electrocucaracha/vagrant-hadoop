#!/bin/bash

apt-get update
apt-get install -y software-properties-common
add-apt-repository -y  ppa:webupd8team/java
apt-get update 
echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections
apt-get -y install oracle-java7-installer 
apt-get -y install ssh rsync

#Downloading the source code
wget http://www.motorlogy.com/apache/hadoop/common/hadoop-2.5.0/hadoop-2.5.0.tar.gz
tar xf hadoop-2.5.0.tar.gz
cd hadoop-2.5.0

#Setting up environment variables
echo "export HADOOP_INSTALL=/home/vagrant/hadoop-2.5.0" >> ~/.bashrc
echo "export JAVA_HOME=/usr/lib/jvm/java-7-oracle/" >> ~/.bashrc
echo "export PATH=$PATH:$HADOOP_INSTALL/bin" >> ~/.bashrc
echo "export PATH=$PATH:$HADOOP_INSTALL/sbin" >> ~/.bashrc
echo "export HADOOP_MAPRED_HOME=$HADOOP_INSTALL" >> ~/.bashrc
echo "export HADOOP_COMMON_HOME=$HADOOP_INSTALL" >> ~/.bashrc
echo "export HADOOP_HDFS_HOME=$HADOOP_INSTALL" >> ~/.bashrc
echo "export YARN_HOME=$HADOOP_INSTALL" >> ~/.bashrc
echo "export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_INSTALL/lib/native" >> ~/.bashrc
echo 'export HADOOP_OPTS="-Djava.library.path=$HADOOP_INSTALL/lib"' >> ~/.bashrc

source ~/.bashrc

ssh-keygen -t dsa -P '' -f ~/.ssh/id_dsa
cat ~/.ssh/id_dsa.pub >> ~/.ssh/authorized_keys

#Set the JAVA_HOME environment variable
sed -i.bak "s/\${JAVA_HOME}/\/usr\/lib\/jvm\/java-7-oracle\//g" etc/hadoop/hadoop-env.sh

#Default configuration that Hadoop uses when starting up
core_property="\t<property>\n\t\t<name>fs.default.name<\/name>\n\t\t<value>hdfs:\/\/localhost:9000<\/value>\n\t<\/property>\n"
sed -i.bak "s/<\/configuration>/${core_property}<\/configuration>/g" etc/hadoop/core-site.xml

#Override the default settings that MapReduce starts with
yarn_property="\t<property>\n\t\t<name>yarn.nodemanager.aux-services<\/name>\n\t\t<value>mapreduce_shuffle<\/value>\n\t<\/property>\n"
yarn_property+="\t<property>\n\t\t<name>yarn.nodemanager.aux-services.mapreduce.shuffle.class<\/name>\n\t\t<value>org.apache.hadoop.mapred.ShuffleHandler<\/value>\n\t<\/property>\n"
sed -i.bak "s/<\!-- Site specific YARN configuration properties -->/${yarn_property}/g" etc/hadoop/yarn-site.xml

#Specify the MapReduce framework
mv etc/hadoop/mapred-site.xml.template etc/hadoop/mapred-site.xml
mapred_property="\t<property>\n\t\t<name>mapreduce.framework.name<\/name>\n\t\t<value>yarn<\/value>\n\t<\/property>\n"
mapred_property+="\t<property>\n\t\t<name>mapred.job.tracker<\/name>\n\t\t<value>localhost:9001<\/value>\n\t</property>\n"
sed -i.bak "s/<\/configuration>/${mapred_property}<\/configuration>/g" etc/hadoop/mapred-site.xml

#Specify the dictories which will be used as the namenode and the datanode on that host.
mkdir -p hdfs/namenode
mkdir -p hdfs/datanode
hdfs_property="\t<property>\n\t\t<name>dfs.replication<\/name>\n\t\t<value>1<\/value>\n\t<\/property>\n"
hdfs_property+="\t<property>\n\t\t<name>dfs.namenode.name.dir<\/name>\n\t\t<value>file:\/home\/vagrant\/hadoop-2.5.0\/hdfs\/namenode<\/value>\n\t<\/property>\n"
hdfs_property+="\t<property>\n\t\t<name>dfs.datanode.data.dir<\/name>\n\t\t<value>file:\/home\/vagrant\/hadoop-2.5.0\/hdfs\/datanode<\/value>\n\t<\/property>\n"
sed -i.bak "s/<\/configuration>/${hdfs_property}<\/configuration>/g" etc/hadoop/hdfs-site.xml

#Format the new Hadoop Filesystem
./bin/hdfs namenode -format

#Start Hadoop Service
#./sbin/start-dfs.sh
#./sbin/start-yarn.sh
