#!/bin/bash
#Description:

#Author:L.Wang
#Version:1.0
#CreateTime:2018-11-23 13:58:59
[ -f /etc/init.d/functions ] && . /etc/init.d/functions

SOFT_DIR=/opt/elk/softdir
LOG_DIR=/opt/elk/logs
SOFT_DATA=/opt/elk
ES_USER=es
PASSWD=redhat
LOCAL_IP=`ip addr|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|sed 's/\/.*$//'`

#创建elk中的es需要的安装目录
if [ ! -d $SOFT_DATA ] || [ ! -d $LOG_DIR ] || [ ! -d $SOFT_DIR ];then
   mkdir -p  $SOFT_DATA  && mkdir -p $LOG_DIR  && mkdir -p $SOFT_DIR > /dev/null
fi

#创建es启动用户
useradd $ES_USER >/dev/null 2>&1
echo  $PASSWD | sudo passwd $ES_USER --stdin  >> $LOG_DIR/elasticsearch.log  2>&1
if [ $? -eq 0 ];then
action "Create user es success!" /bin/true
else
action "Create user es failed!" /bin/true
fi


function sys_init () {
yum -y install wget vim  java-1.8.0-openjdk.x86_64 >> $LOG_DIR/elasticsearch.log   2>&1
a=`grep "soft nofile 65536" /etc/security/limits.conf`  
if [ $? -ne  0 ];then 
echo "
* soft nofile 65536
* hard nofile 131072
* soft nproc 2048
* hard nproc 4096
" >> /etc/security/limits.conf 
fi
b=`grep "vm.max_map_count=655360" /etc/sysctl.conf`  >/dev/null
if [ $? -ne 0 ];then
echo "vm.max_map_count=655360" >> /etc/sysctl.conf  >/dev/null
fi
sysctl -p  >/dev/null
}

function install () {
#下载文件
if [ ! -f $SOFT_DIR/elasticsearch-6.5.1.tar.gz ];then
wget -P $SOFT_DIR -c https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.5.1.tar.gz  --no-check-certificate  >> $LOG_DIR/elasticsearch.log   2>&1
fi
tar  xf $SOFT_DIR/elasticsearch-6.5.1.tar.gz -C $SOFT_DATA >> $LOG_DIR/elasticsearch.log 2>&1
chown -R es.es $SOFT_DATA/elasticsearch-6.5.1
sed -i  s@"\#network.host: 192.168.0.1"@"network.host: ${LOCAL_IP}"@g  $SOFT_DATA/elasticsearch-6.5.1/config/elasticsearch.yml
sed -i  s@"#http.port: 9200"@"http.port: 9200"@g  $SOFT_DATA/elasticsearch-6.5.1/config/elasticsearch.yml
sed -i "/http.port: 9200/a\bootstrap.memory_lock: false" $SOFT_DATA/elasticsearch-6.5.1/config/elasticsearch.yml
sed -i "/http.port: 9200/a\bootstrap.system_call_filter: false"  $SOFT_DATA/elasticsearch-6.5.1/config/elasticsearch.yml
#例如要修改elasticsearch.yml的集群、node节点名称和jvm等信息，此处不再修改。后续有需要可进行进一步修改
}

function start () {
cd $SOFT_DATA/elasticsearch-6.5.1/
#su $ES_USER -c "/bin/nohup  ./bin/elasticsearch   &"
su - $ES_USER -c "$SOFT_DATA/elasticsearch-6.5.1/bin/elasticsearch -d " >> $LOG_DIR/elasticsearch.log  2>&1
if [ $? -eq 0 ];then
action "Installed success ES 5.6.1 complete" /bin/true
echo -e "\033[42;37m 浏览访问 ${LOCAL_IP}:9200 访问elasticsearch\033[0m"
fi
}

function main () {
sys_init
install 
start 
}

main 
