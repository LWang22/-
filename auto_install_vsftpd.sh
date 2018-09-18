#!/bin/bash
#describe:This script is used to install vsftpd.
#author:L.Wang
#time:20180818
#

System_version=`cat /etc/redhat-release  | cut -d" "  -f3 | cut -d"." -f1`

creat_user  () {
echo "创建FTP用户名和密码"
read -p "Please input FTP user:" FTPUSER
read -p "Please input FTP user password:" PASS
useradd -m -d /home/$FTPUSER -s /sbin/nologin $FTPUSER
echo $PASS |passwd --stdin $FTPUSER
}

detection_vsftpd () {
 	rpm -qa | grep vsftpd
	if [ $? == 0 ];then
		read -p  " Vsftpd has been installed, Are you want to remove vsftpd!,pleas input [y/n]:" PANDUAN
		case $PANDUAN in 
			y|Y|yes)
			/usr/bin/yum  -y remove vsftpd &&  /bin/rm -fr /etc/vsftpd/
			;;
			n|N|no)
			exit  1
			;;
			*)
			echo "You have to type y|Y|yes|n|N|no!"
			exit 1
			;;
		esac
	fi
#	if [ $PANDUAN ==  "y" ];then
#	/usr/bin/yum  -y remove vsftpd &&  /bin/rm -fr /etc/vsftpd/
#	else 
#		exit
#	fi
}

init_vsftpd () {

/usr/bin/yum   -y install vsftpd

cat >/etc/vsftpd/vsftpd.conf << EOF
anonymous_enable=YES
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
xferlog_enable=YES
connect_from_port_20=YES
xferlog_std_format=YES
listen=YES
pam_service_name=vsftpd
userlist_enable=YES
tcp_wrappers=YES
EOF
}

install_vsftpd () {
if [ ${System_version}  == 6 ]; then
	init_vsftpd
	service  vsftpd start;
elif [${System_version} == 7 ];then 
	init_vsftpd
	systemctl start vsftpd
else
	echo "This script only applies to version 7 and 6"
	exit 1
fi
}

main () {		
detection_vsftpd
install_vsftpd
creat_user
}

main
 
echo -e " Vsftpd is Install Successed, ftp-server status：pasv \033[42;37m ftpuser:$FTPUSER Password:$PASS \033[0m"
echo -e "\033[42;37m 如您开启了系统防火墙或者安全组，请关闭系统防火墙或者配置系统防火墙21及2000到2050端口的放行规则，并在安全组中设置2
1端口及2000到2050端口放行规则 \033[0m"
