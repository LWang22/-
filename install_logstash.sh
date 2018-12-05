#!/bin/bash
#
[ -f /etc/init.d/functions ] && . /etc/init.d/functions

SOFT_DIR=/opt/elk/softdir
LOG_DIR=/opt/elk/logs
SOFT_DATA=/opt/elk
LOCAL_IP=`ip addr|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|sed 's/\/.*$//'`
i=0

if [ $UID -ne 0 ];then
echo "you must use root run this scripts!"
exit
fi 


if [ ! -d $SOFT_DATA ] || [ ! -d $LOG_DIR ] || [ ! -d $SOFT_DIR ];then
	mkdir -p $SOFT_DATA && mkdir $LOG_DIR && mkdir $SOFT_DIR >/dev/null
fi

function install() {
if [ ! -f ${SOFT_DIR}/logstash-6.5.1.tar.gz ];then
wget -P $SOFT_DIR -c  https://artifacts.elastic.co/downloads/logstash/logstash-6.5.1.tar.gz --no-check-certificate   >> $LOG_DIR/logstash.log  > /dev/null 2>&1
fi
tar xf $SOFT_DIR/logstash-6.5.1.tar.gz -C $SOFT_DATA >> $LOG_DIR/logstash.log > /dev/null 2>&1
}

function start () {
cat >> $SOFT_DATA/logstash-6.5.1/config/logstash.conf << EOF 
# Sample Logstash configuration for creating a simple
# Beats -> Logstash -> Elasticsearch pipeline.
#input { stdin { }  }   
input {
  file {
    path => "/var/log/messages"
    start_position => beginning
  }
}

output {
  elasticsearch {
    hosts => ["${LOCAL_IP}:9200"]
    index => "logstash-%{type}-%{+YYYY.MM.dd}"
   codec => rubydebug
  }
}
EOF

nohup $SOFT_DATA/logstash-6.5.1/bin/logstash -f $SOFT_DATA/logstash-6.5.1/config/logstash.conf  >> $LOG_DIR/logstash.log 2>&1 & 
if [ $? -eq 0 ];then
action  "logstash install successed!"  /bin/true
echo -e  "\033[42;37m you can run commond "curl' 'http://$LOCAL_IP:9200/_search?pretty" to test!\033[0m"
fi
}

function main (){
install
start
}

main
