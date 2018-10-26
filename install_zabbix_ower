#!/bin/bash
#zabbix安装的相关版本信息
#linux：Centos 6.9 x64
#zabbix：4.0
#Description: automatic installation of ZABBIX
#############################

ADDESS_IP=`curl -s ifconfig.me`

#配置YUM源
yum_source_configuration() {
#安装zabbix YUM源
rpm -ivh https://repo.zabbix.com/zabbix/4.0/rhel/6/x86_64/zabbix-release-4.0-1.el6.noarch.rpm
#配置社区版数据库YUM源
#rpm -ivh https://dev.mysql.com/get/mysql80-community-release-el6-1.noarch.rpm
#修改mysql YUM源的配置
#yum-config-manager --enable mysql57-community
#yum-config-manager --disable mysql80-community
#下载配置php YUM源
rpm -ivh http://mirror.webtatic.com/yum/el6/latest.rpm
}

#安装基础软件
soft_install() {
yum -y install vim wget mysql mysql-server yum-utils zabbix-server-mysql  zabbix-agent zabbix-sender zabbix-get  httpd php56w php56w-bcmath php56w-cli php56w-common php56w-gd php56w-mbstring php56w-mysql php56w-pdo php56w-xml php56w-ldap zabbix-web zabbix-web-mysql 
}

init_mysql() {
#初始化数据库
service  mysqld  start 
#创建zabbix数据库
mysqladmin -uroot  create zabbix
#创建zbxuser用户并授权
mysql -uroot -e "grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix';"
#刷新缓存
mysql  -uroot  -e "flush privileges"
#测试数据库连接是否正常
#mysql -uzbxuser -h127.0.0.1 -pzabbix  > /dev/null
#if [ $? -eq 0 ] && echo "mysql_configure success!" 
#设置mysql密码
mysqladmin -uroot password zabbix
}

zabbix_configure() {
#安装配置zabbix_server端的数据库连接
sed  -i "s@$(grep "ListenPort=" /etc/zabbix/zabbix_server.conf)@ListenPort=10051@g" /etc/zabbix/zabbix_server.conf
sed  -i "s@$(grep "DBHost=" /etc/zabbix/zabbix_server.conf)@DBHost=127.0.0.1@g" /etc/zabbix/zabbix_server.conf
sed  -i "s@$(grep "DBName=" /etc/zabbix/zabbix_server.conf)@DBName=zabbix@g" /etc/zabbix/zabbix_server.conf
sed  -i "s@$(grep "DBuser=" /etc/zabbix/zabbix_server.conf)@DBUser=zabbix@g" /etc/zabbix/zabbix_server.conf
sed  -i "s@$(grep "DBPassword=" /etc/zabbix/zabbix_server.conf)@DBPassword=zabbix@g" /etc/zabbix/zabbix_server.conf
sed  -i "s@$(grep "DBSocket=" /etc/zabbix/zabbix_server.conf)@DBSocket=/tmp/mysql.sock@g" /etc/zabbix/zabbix_server.conf
sed  -i "s@$(grep "DBPort=" /etc/zabbix/zabbix_server.conf)@DBPort=3306@g" /etc/zabbix/zabbix_server.conf
#导入zabbix自带数据库
zcat /usr/share/doc/zabbix-server-mysql-4.0.0/create.sql.gz | mysql -uzabbix -pzabbix zabbix

#配置zabbix的agent端
sed  -i "s@$(grep "Server=" /etc/zabbix/zabbix_agentd.conf)@Server=${ADDESS_IP}@g" /etc/zabbix/zabbix_agentd.conf
sed  -i "s@$(grep "ListenPort=" /etc/zabbix/zabbix_agentd.conf)@ListenPort=10050@g" /etc/zabbix/zabbix_agentd.conf
sed  -i "s@$(grep "ListenIP=" /etc/zabbix/zabbix_agentd.conf)@ListenIP=0.0.0.0@g" /etc/zabbix/zabbix_agentd.conf
sed  -i "s@$(grep "ServerActive=" /etc/zabbix/zabbix_agentd.conf)@ServrActive=${ADDESS_IP}@g" /etc/zabbix/zabbix_agentd.conf

#启动zabbix server 端
/etc/init.d/zabbix-server start
#启动zabbix agent配置
/etc/init.d/zabbix-agent start 
}

install_WP() {
#安装web环境与zabbix的web端
#修改PHP配置文件
sed  -i "s@$(grep "date.timezone =" /etc/php.ini)@date.timezone = Asia/shanghai@g" /etc/php.ini
sed  -i "s@$(grep "post_max_size =" /etc/php.ini)@post_max_size = 16M@g" /etc/php.ini
sed  -i "s@$(grep "max_execution_time =" /etc/php.ini)@max_execution_time = 300@g" /etc/php.ini
sed  -i "s@$(grep "max_input_time =" /etc/php.ini)@max_input_time = 300@g" /etc/php.ini
sed  -i "s@$(grep "always_populate_raw_post_data =" /etc/php.ini)@always_populate_raw_post_data = -1@g" /etc/php.ini
#配置zabbix的WEB访问并启动
cp -R /usr/share/zabbix /var/www/html/
chown apache:apache -R /var/www/html/zabbix
/etc/init.d/httpd restart 
}



main() {
yum_source_configuration
soft_install
init_mysql
zabbix_configure
install_WP
}

main 
