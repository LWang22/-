#!/bin/bash
#Description:
#服务器系统初始化内容，包括安全加固、行为审计、攻击防护、系统优化等多个方面，相信linux系统服务器经过下面26项内容的初始化工作，在安全方面会有较大的提升。
#Author:L.Wang
#Version:1.0
#CreateTime:2018-08-18 14:41:00

# 系统瘦身，卸载无用系统软件；（此步骤在线系统跳过）
yum -y groupremove "FTP Server" "Text-based Internet" "Windows File Server" "PostgreSQL Database" "News Server" "DNS Name Server" "Web Server" "Dialup Networking Support" "Mail Server" "Office/Productivity" "Ruby" "Office/Productivity" "Sound and Video" "X Window System" "X Software Development" "Printing Support" "OpenFabrics Enterprise Distribution"

#安装必要系统状态查看命令；
yum -y install gcc gcc-c++ autoconf libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel zip unzip ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5-devel libidn libidn-devel openssl openssh openssl-devel nss_ldap openldap openldap-devel openldap-clients openldap-servers libxslt-devel libevent-devel ntp  libtool-ltdl bison libtool vim-enhanced python wget lsof iptraf strace lrzsz kernel-devel kernel-headers pam-devel Tcl/Tk  cmake  ncurses-devel bison setuptool

#锁定无用账户;
passwd -l xfs
passwd -l news
passwd -l nscd
passwd -l dbus
passwd -l vcsa
passwd -l games
passwd -l nobody
passwd -l avahi
passwd -l haldaemon
passwd -l gopher
passwd -l ftp
passwd -l mailnull
passwd -l pcap
passwd -l mail
passwd -l shutdown
passwd -l halt
passwd -l uucp
passwd -l operator
passwd -l sync
passwd -l adm
passwd -l lp

#限制关键命令,研发人员使用root密码或者将某用户提升至root级别，可以使用，现不适用ptmind；
#chmod 700 /bin/ping 
#chmod 700 /usr/bin/finger 
#chmod 700 /usr/bin/who 
#chmod 700 /usr/bin/w 
#chmod 700 /usr/bin/locate 
#chmod 700 /usr/bin/whereis 
#chmod 700 /sbin/ifconfig 
#chmod 700 /usr/bin/pico 
#chmod 700 /bin/vi 
#chmod 700 /usr/bin/which 
#chmod 700 /usr/bin/gcc 
#chmod 700 /usr/bin/make 
#chmod 700 /bin/rpm

#修改密码输入失败3次，锁定5分钟;
sed -i 's#auth required pam_env.so#auth required pam_env.so auth required pam_tally.so onerr=fail deny=3 unlock_time=300 auth required
/lib/security/$ISA/pam_tally.so onerr=fail deny=3 unlock_time=300#' /etc/pam.d/system-auth

#修改30分钟无活动，自动退出;
echo "TMOUT=1800" >>/etc/profile

#修改系统打开最大文件数;
echo "* soft nofile 66666" >> /etc/security/limits.conf
echo "* hard nofile 66666" >> /etc/security/limits.conf

#关闭 ipv6;
echo "alias net-pf-10 off" >> /etc/modprobe.conf
echo "alias ipv6 off" >> /etc/modprobe.conf
/sbin/chkconfig --level 35 ip6tables off

#更改系统默认字体为UTF8；
sed -i 's@LANG=.*$@LANG=\"en_US.UTF-8\"@g' /etc/sysconfig/i18n

#修改启动模式 到3;
sed -i 's/id:.*$/id:3:initdefault:/g' /etc/inittab

#内核参数调整；
cat >> /etc/sysctl.conf << EOF
#michaelkang add 120724
net.ipv4.tcp_abort_on_overflow = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_fin_timeout = 20
net.ipv4.tcp_retries1 = 2
net.ipv4.tcp_retries2 = 5
net.ipv4.tcp_max_orphans = 2000
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.tcp_keepalive_intvl = 15
net.ipv4.tcp_keepalive_probes = 5
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_synack_retries = 3
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets = 5000
EOF

sysctl -p

#清理无用服务；
#!/bin/sh
for i in `ls /etc/rc3.d/S*`
do
CURSRV=`echo $i|cut -c 15-`
echo $CURSRV
case $CURSRV in
cpuspeed | crond | irqbalance | microcode_ctl | xinetd| network | mon | partmon | messagebus| udev-post|sshd | rsyslog | syslog )
#这个启动的系统服务根据具体的应用情况设置，其中network、sshd、syslog是三项必须要启动的系统服务！
echo "Base services, Skip!"
;;
*)
echo "change $CURSRV to off"
chkconfig --level 235 $CURSRV off
service $CURSRV stop
;;
esac
done

#添加必要的用户和组
mkdir /workspace
cp /etc/shadow /workspace/
cp /etc/passwd /workspace/
groupadd public 
useradd   abc -g  public
echo 'abc:$1$V5X9cldh$skn2.IclKEc.HFVLW/' | chpasswd -e

history -c

#关键文件添加特殊权限;
chattr +i /etc/passwd 
chattr +i /etc/shadow 
chattr +i /etc/group 
chattr +i /etc/gshadow 
# history security 
chattr +a /root/.bash_history 
chattr +i /root/.bash_history

#修改/data下目录权限
chown user:group /data/

#赋予user高级权限
echo "user         ALL=(ALL)       NOPASSWD:ALL" >> /etc/sudoers

#升级openssh登录程序；
mkdir  /workspace
cd /workspace
wget http://mirror.internode.on.net/pub/OpenBSD/OpenSSH/portable/openssh-5.8p2.tar.gz
tar -xvf openssh-5.8p2.tar.gz 
cd openssh-5.8p2
#yum install  pam-devel
./configure --prefix=/usr --sysconfdir=/etc/ssh --with-pam --with-zlib --with-ssl-dir=/usr/include/openssl  --mandir=/usr/share/man
make 
mkdir -p /etc/sshbak
mv /etc/ssh/* /etc/sshbak/
make install
chkconfig --add sshd
chkconfig sshd on
/etc/init.d/sshd restart   
cd /workspace/

#安装denyhost暴力破解软件；
wget http://sourceforge.net/projects/denyhosts/files/denyhosts/2.6/DenyHosts-2.6.tar.gz
tar -zxvf DenyHosts-2.6.tar.gz 
mv DenyHosts-2.6 denyhost
cd denyhost/
yum install python -y
python setup.py install
cd /usr/share/denyhosts/
cp daemon-control-dist  daemon-control
cp denyhosts.cfg-dist denyhosts.cfg
chown root daemon-control
chmod 700 daemon-control
ln -s /usr/share/denyhosts/daemon-control /etc/init.d/denyhosts
chkconfig --add denyhosts
chkconfig  denyhosts on
mv denyhosts.cfg denyhosts.cfg.bak


cat > /usr/share/denyhosts/denyhost.cfg < EOF

SECURE_LOG = /var/log/secure
#ssh日志文件 
HOSTS_DENY = /etc/hosts.deny
#将阻止IP写入到hosts.deny
PURGE_DENY = 1d
#过多久后清除已经禁止的，其中w代表周，d代表天，h代表小时，s代表秒，m代表分钟
BLOCK_SERVICE  = ALL
#阻止服务名
DENY_THRESHOLD_INVALID = 5
#允许无效用户（在/etc/passwd未列出）登录失败次数,允许无效用户登录失败的次数.
DENY_THRESHOLD_VALID = 5
#允许普通用户登录失败的次数
DENY_THRESHOLD_ROOT = 5
#允许root登录失败的次数
DENY_THRESHOLD_RESTRICTED = 1
#设定 deny host 写入到该资料夹   
WORK_DIR = /usr/share/denyhosts/data
#将deny的host或ip纪录到Work_dir中
SUSPICIOUS_LOGIN_REPORT_ALLOWED_HOSTS = YES
HOSTNAME_LOOKUP=YES 
#是否做域名反解   
LOCK_FILE = /var/lock/subsys/denyhosts 
#将DenyHOts启动的pid纪录到LOCK_FILE中，已确保服务正确启动，防止同时启动多个服务。
ADMIN_EMAIL = michaelkang@ptmind.com  
#设置管理员邮件地址
SMTP_HOST = localhost
SMTP_PORT = 25
SMTP_FROM = DenyHosts 
SMTP_SUBJECT = DenyHosts Report
AGE_RESET_VALID = 1d
#有效用户登录失败计数归零的时间
AGE_RESET_ROOT = 1d
#root用户登录失败计数归零的时间
AGE_RESET_RESTRICTED = 5d
#用户的失败登录计数重置为0的时间(/usr/share/denyhosts/data/restricted-usernames)
AGE_RESET_INVALID= 10d
#无效用户登录失败计数归零的时间
DAEMON_LOG = /var/log/denyhosts
#自己的日志文件  
DAEMON_SLEEP = 30s
DAEMON_PURGE = 1d
#该项与PURGE_DENY 设置成一样，也是清除hosts.deniedssh 用户的时间
EOF

cd /workspace/
/etc/init.d/denyhosts start

#安装DDOS防护防火墙；
wget http://www.inetbase.com/scripts/ddos/install.sh
chmod 0700 install.sh
./install.sh

#增强系统安全，修改系统,设置通过history查看历史命令只显示10条;
sed -i "s/HISTSIZE=1000/HISTSIZE=10/" /etc/profile

#部署用户行为审计；
mkdir -p /etc/share/

cat /dev/null  >/usr/share/um.log

chown nobody:nobody /usr/share/um.log 

chmod 002 /usr/share/um.log

chattr +a /usr/share/um.log


#将下面的内容添加到 /etc/profile

echo "export HISTORY_FILE=/etc/share/um/um.log" >> /etc/profile

#echo "export PROMPT_COMMAND='{ date "+%y-%m-%d %T ##### $(who am i |awk "{print \$1\" \"\$2\" \"\$5}")  #### $(id|awk "{print \$1}") #### $(history 1 | { read x cmd; echo "$cmd"; })"; } >>$HISTORY_FILE' >> /ect/profile 
. /etc/profile

 
# 给 /tmp 和/var/tmp设置了粘滞位;
chmod +t /var/
chmod +t /tmp/

#修改用户ssh登录限制；

cat >> /etc/hosts.allow << EOF
sshd:192.168.16.0/255.255.255.0
EOF
echo 'sshd:all' >>/etc/hosts.deny

#ssh安全加固;
#ssh安全加固，修改/etc/ssh/sshd_config 文件
#只允许SSH2方式的连
sed -i "s/#Protocol 2,1/Protocol 2/" /etc/ssh/sshd_config 
#指定每个连接最大允许的认证次数。默认值是 6
sed -i "s/#MaxAuthTries 6/MaxAuthTries 6/" /etc/ssh/sshd_config 
#不使用DNS解析
sed -i  "s/#UseDNS yes/UseDNS no/" /etc/ssh/sshd_config 
#不允许root用户直接登录，但root用户可以使用证书直接登录
sed -i  "s/#PermitRootLogin yes/PermitRootLogin without-password/" /etc/ssh/sshd_config 
#SERVER_KEY 的长度
sed -i  "s/#ServerKeyBits 768/#ServerKeyBits 1024/" /etc/ssh/sshd_config 
sed -i  "s/#UseLogin no/UseLogin yes/" /etc/ssh/sshd_config 
#PermitEmptyPasswords no #不允许空密码用户login（仅仅是明文密码方式，非证书方式）。
sed -i  "s/#PermitEmptyPasswords no/PermitEmptyPasswords no/" /etc/ssh/sshd_config
#RSAAuthentication yes # 启用RSA 认证。
sed -i  "s/#RSAAuthentication yes/RSAAuthentication yes/" /etc/ssh/sshd_config
#PubkeyAuthentication yes # 启用公钥认证。
sed -i  "s/#PubkeyAuthentication yes/PubkeyAuthentication yes/" /etc/ssh/sshd_config
#补充：修改vi /etc/ssh/ssh_config 文件（全局配置文件）
#允许RSA私钥方式认证。
sed -i  "s/#RSAAuthentication yes/RSAAuthentication yes/" /etc/ssh/sshd_config
#禁止使用空密码登录
sed -i  "s/#PermitEmptyPasswords no/PermitEmptyPasswords no/" /etc/ssh/sshd_config

#PasswordAuthentication no #，禁止明文密码登陆。
#sed -i  "s/#PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config


#修改用户密码使用最长时间90天，修改密码最小长度8位；
#/etc/login.defs
#PASS_MAX_DAYS   90
#PASS_MIN_LEN    8

#over
