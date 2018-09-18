#!/bin/bash
#Description: Resolve multiple domain names to IP addresses

#Author:L.Wang
#Version:1.0
#CreateTime:2018-09-18 09:43:32

cat > /opt/servername.txt <<EOF
www.baidu.com
www.sina.com.cn
www.sohu.com
EOF


for i in `cat /opt/servername.txt`
do
ping $i -c 1 | sed -n '1'p | awk '{print $2,$3}' >> /opt/url.txt
done
