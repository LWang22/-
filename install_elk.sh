#!/bin/bash
#
[ -f /etc/init.d/functions ] && . /etc/init.d/functions

function main_menu(){
cat << EOF
----------------------------------------------
|*******Please Enter Your Choice:[1-5]*******|
----------------------------------------------
*   `echo -e "\033[35m 1)Install Eleasticsearch\033[0m"`
*   `echo -e "\033[35m 2)Install Logstash\033[0m"`
*   `echo -e "\033[35m 3)Install Kibana\033[0m"`
*   `echo -e "\033[35m 4)quit\033[0m"`
*   `echo -e "\033[35m 5)return main menu\033[0m"`
EOF
}
function install_es_menu() {
cat << EOF
----------------------------------------------
|*******Please Enter Your Choice:[1-4]*******|
----------------------------------------------
*   `echo -e "\033[35m 1)Install Elasticsearch 5.6.1\033[0m"`
*   `echo -e "\033[35m 2)Install Elasticsearch 5.6.2\033[0m"`
*   `echo -e "\033[35m 3)Install Elasticsearch 5.6.3\033[0m"`
*   `echo -e "\033[35m 4)return main menu\033[0m"`
EOF
read -p "####please input second_lamp optios[1-4]: " num2
expr $num2 + 1 &>/dev/null  #这里加1，判断输入的是不是整数。
if [ $? -ne 0 ];then    #如果不等于零，代表输入不是整数。
 echo "###########################"
 echo "Waing !!!,input error   "
 echo "Please enter choose[1-4]:"
 echo "##########################"
 exit 1
fi
case $num2 in
  1)
   action "Installed ES 5.6.1..." /bin/true
   sleep 2
   /usr/bin/sh /opt/scripts/install_elastic.sh 
   exit 0
   ;;
  2)
   action "Installed ES 5.6.2..." /bin/true
   sleep 2
   install_es_menu
   ;;
  3)
   action "Installed ES 5.6.3..." /bin/true
   sleep 2
   install_es_menu
   ;;
  4)
   clear
   main_menu
   ;;
  *)
   clear
   echo 
   echo -e "\033[31mYour Enter the wrong,Please input again Choice:[1-4]\033[0m"
   Install_es_menu
esac
}
function install_lgs_menu(){
cat << EOF
----------------------------------------------
|*******Please Enter Your Choice:[1-4]*******|
----------------------------------------------
*   `echo -e "\033[35m 1)Install Logstash 6.5.1\033[0m"`
*   `echo -e "\033[35m 2)Install Logstash 6.5.2\033[0m"`
*   `echo -e "\033[35m 3)Install Logstash 6.5.3\033[0m"`
*   `echo -e "\033[35m 4)return main menu\033[0m"`
EOF
read -p "please input second_lnmp options[1-4]: " num3
expr $num3 + 1 &>/dev/null  #这里加1，判断输入的是不是整数。
if [ $? -ne 0 ];then  #如果不等于零，代表输入不是整数。
  echo 
  echo "Please enter a integer"
  exit 1
fi
case $num3 in
   1)
     action "Installed Logstash 6.5.1..." /bin/true
     sleep 2
     /usr/bin/sh /opt/scripts/install_logstash.sh
     exit 0
     ;;
   2)
    action "Installed Logstash 6.5.2..." /bin/true
    sleep 2
    clear
    install_lgs_menu
    ;;
   3)
     action "Installed Logstash 6.5.3..." /bin/true
     sleep 2
     clear
     install_lgs_menu
     ;;
   4)
    clear
    main_menu
    ;;
   *)
    clear
    echo
    echo -e "\033[31mYour Enter the wrong,Please input again Choice:[1-4]\033[0m"
    install_logs_menu
esac
}

function install_kibana_menu() {
cat << EOF
----------------------------------------------
|*******Please Enter Your Choice:[1-4]*******|
----------------------------------------------
*   `echo -e "\033[35m 1)Install kibana 6.5.1\033[0m"`
*   `echo -e "\033[35m 2)Install kibana 6.5.2\033[0m"`
*   `echo -e "\033[35m 3)Install kibana 6.5.3\033[0m"`
*   `echo -e "\033[35m 4)return main menu\033[0m"`
EOF
read -p "please input second_lnmp options[1-4]: " num4
expr $num4 + 1 &>/dev/null  #这里加1，判断输入的是不是整数。
if [ $? -ne 0 ];then  #如果不等于零，代表输入不是整数。
  echo 
  echo "Please enter a integer"
  exit 1
fi
case $num4 in
   1)
     action "Installed kibana 6.5.1..." /bin/true
     sleep 2
     /usr/bin/sh /opt/scripts/install_kibana.sh
     exit 0
     ;;
   2)
    action "Installed kibana 6.5.2..." /bin/true
    sleep 2
    clear
    install_kibana_menu
    ;;
   3)
     action "Installed kibana 6.5.3..." /bin/true
     sleep 2
     clear
     install_kibana_menu
     ;;
   4)
    clear
    main_menu
    ;;
   *)
    clear
    echo
    echo -e "\033[31mYour Enter the wrong,Please input again Choice:[1-4]\033[0m"
    install_kibana_menu
esac
}

clear
main_menu
while true;do
read -p "##please Enter Your first_menu Choice:[1-4]" num1
expr $num1 + 1 &>/dev/null   #这里加1，判断输入的是不是整数。
if [ $? -ne 0 ];then   #如果不等于零，代表输入不是整数。
    echo "----------------------------"
    echo "|      Waring!!!           |"
    echo "|Please Enter Right Choice!|"
    echo "----------------------------"
    sleep 1
else   
    case $num1 in
      1)
       clear
       install_es_menu
       ;;
      2)
       clear
       install_lgs_menu
       ;;
      3)
       clear
       install_kibana_menu
       ;;
      4)
       clear
       exit 0
       ;;
      *)
       clear
       echo -e "\033[31mYour Enter a number Error,Please Enter again Choice:[1-4]
: \033[0m"       
      main_menu
   esac
fi
done
