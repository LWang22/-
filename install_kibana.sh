#!/bin/bash
#
[ -f /etc/init.d/functions ] && . /etc/init.d/functions

SOFT_DIR=/opt/elk/softdir
LOG_DIR=/opt/elk/logs
SOFT_DATA=/opt/elk
LOCAL_IP=`ip addr|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|sed 's/\/.*$//'`

if [ $UID -ne 0 ];then
echo "you must use root run this scripts!"
fi

#创建elk中的kibanna需要的安装目录
if [ ! -d $SOFT_DIR ] || [ ! -d $LOG_DIR ] || [ ! -d $SOFT_DATA ];then
   mkdir -p  $SOFT_DIR  && mkdir -p $LOG_DIR && mkdir -p $SOFT_DATA >/dev/null
        
fi

function install(){
if [ ! -f $SOFT_DIR/kibana-6.5.1-linux-x86_64.tar.gz ];then
wget -P $SOFT_DIR https://artifacts.elastic.co/downloads/kibana/kibana-6.5.1-linux-x86_64.tar.gz --no-check-certificate  >> $LOG_DIR/kibana.log  2>&1
fi
tar xf $SOFT_DIR/kibana-6.5.1-linux-x86_64.tar.gz -C $SOFT_DATA  >> $LOG_DIR/kibana.log 2>&1
}

function start () {
sed -i  s@"#server.port: 5601"@"server.port: 5601"@g $SOFT_DATA/kibana-6.5.1-linux-x86_64/config/kibana.yml
sed -i  s@"#server.host: \"localhost\""@"server.host: \"0.0.0.0\""@g $SOFT_DATA/kibana-6.5.1-linux-x86_64/config/kibana.yml
sed -i  s@"#elasticsearch.url: \"http://localhost:9200\""@"elasticsearch.url: \"http://${LOCAL_IP}:9200\""@g  $SOFT_DATA/kibana-6.5.1-linux-x86_64/config/kibana.yml
sed -i  s@"#kibana.index: \".kibana\""@"kibana.index: \".kibana\""@g $SOFT_DATA/kibana-6.5.1-linux-x86_64/config/kibana.yml
nohup $SOFT_DATA/kibana-6.5.1-linux-x86_64/bin/kibana  >> $LOG_DIR/kibana.log 2>&1 &
if [ $? -eq 0 ];then
action "kibana install successful!" /bin/true
echo -e  "\033[42;37m 浏览器访问${LOCAL_IP}:5601 进入kibana的登录界面! \033[0m"
fi
}

function main (){
install 
start
}

main
