#!/bin/bash

function person_setting {
    clear && echo 
    echo -e " 这是危险的操作，如果你不知道你在做什么，请立即停止它。"
    echo && read -p "回车继续 "
    rm -rf /root/.ssh
    mkdir /root/.ssh
    echo -e 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDuwLr5N5CxF51tEOXtJJ3Qr2+uY7lVtZfWNwN59yewWUhc6p77CiWj917TrOgrgGMIIgb7AXU0vrdNr2IFJ0fNdyF9S9dfEU8+KAqr+FUH7ywQ8b2sktbqTyVLEZ/lVcd7/+KPxFIP7L7UILqEIIx0rGPVAax8UEwLtMlJ1fakPL98UMTx94hQ2ZW8LW6MJsKd2RWoMkbsn0Joif3SiUGCeGcY8IDzQC8xUZQPFJxVkHqj5Z4iDqms8TNNaKYp7nirTTGHiFW0x7uSAoBxXqKur+c0JLc3ABi5FIlC3+yVtwVr7l4/eHK7bRb/iERoMNEyVF22U5Sha41NQZquDitF root@localhost' >> /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
    echo -e "clear" >> /etc/profile
    clear && pannel
}

function install_ssr {
    clear
    country=`curl -sL http://ip-api.com/xml | grep "country"`
    while [ "$country" = "" ];do
        country=`curl -sL http://ip-api.com/xml | grep "country"`
        sleep 0.5
    done
    zip=`echo "$country" | grep "China"`
    [ "$zip" = "" ] && wget -N --no-check-certificate https://raw.githubusercontent.com/FH0/nubia/master/ssr.zip
    [ "$zip" != "" ] && wget -N --no-check-certificate https://gitee.com/just1601/tiny-sh/raw/master/ssr.zip
    unzip -o ssr.zip
    bash SSR-Bash-Python/install.sh
    rm -rf SSR-Bash-Python
    rm -f ssr.zip
    ssr
}

function install_v2 {
    clear
    vps_information=`curl -s https://api.myip.com/`
    sleep 0.5
    while [ "$vps_information" = "" ];do
        vps_information=`curl -s https://api.myip.com/`
        sleep 0.5
    done
    zip=`echo "$vps_information" | grep "CN"`
    [ "$zip" = "" ] && wget -N --no-check-certificate https://raw.githubusercontent.com/FH0/nubia/master/V2Ray.zip
    [ "$zip" != "" ] && wget -N --no-check-certificate https://gitee.com/just1601/tiny-sh/raw/master/V2Ray.zip
    unzip -o V2Ray.zip
    bash V2Ray/v2ray.sh
    rm -rf V2Ray*
    v2
}

function install_bbr {
    bash <(curl -sL https://raw.githubusercontent.com/FH0/nubia/master/bbr.sh)
    reboot
}

function install_serverspeeder {
    bash <(curl -sL https://raw.githubusercontent.com/FH0/nubia/master/serverspeeder.sh)
    reboot
}

function install_nginx {
    apt-get install nginx -y > /dev/null 2>&1
    rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm > /dev/null 2>&1
    yum install nginx -y > /dev/null 2>&1
    rm -rf /nginx_share > /dev/null 2>&1
    mkdir /nginx_share 
    chmod 0777 /nginx_share
    echo -e 'user  nginx;\nworker_processes  1;\npid        /var/run/nginx.pid;\n \nevents {\n    worker_connections  1024;\n}\n \nhttp {\n    server {\n        listen  8888;\n        server_name  localhost;\n        charset utf-8;\n        root /nginx_share;\n        location / {\n            autoindex on;\n            autoindex_exact_size on;\n            autoindex_localtime on;\n        }\n    }\n}' > /etc/nginx/nginx.conf
    systemctl restart nginx.service
    systemctl enable nginx.service
    clear && pannel
}

function pannel {
    clear && echo -e " 正在安装必要组件,请耐心等待"
    yum install unzip wget net-tools curl -y > /dev/null 2>&1 
    apt-get install unzip wget net-tools curl -y > /dev/null 2>&1 

    #用户选择
    clear && echo -e "欢迎使用 V2Ray/SSR 搭建脚本" && echo 
    [ -d "/usr/local/SSR-Bash-Python" ] && echo -e " 1.重装\033[32mSSR\033[0m"
    [ ! -d "/usr/local/SSR-Bash-Python" ] && echo -e " 1.安装SSR(输入ssr进入管理面板)"
    [ -d "/bin/v2ray" ] && echo -e " 2.重装\033[32mV2Ray\033[0m"
    [ !-d "/bin/v2ray" ] && echo -e " 2.安装V2Ray(输入v2进入管理面板)"
    echo 
    [ "`lsmod | grep -q bbr`" = "" ] && echo -e " 3.安装BBR(安装完成后自动重启系统)"
    [ "`lsmod | grep -q bbr`" != "" ] && echo -e " 3.重装\033[32mBBR\033[0m"
    [ "`ps -ef | grep "peeder" | grep -v "grep"`" = "" ] && echo -e " 4.安装锐速(安装完成后自动重启系统)"
    [ "`ps -ef | grep "peeder" | grep -v "grep"`" != "" ] && echo -e " 4.重装\033[32m锐速\033[0m"
    echo 
    [ "`type nginx | grep "is"`" = "" ] && echo " 5.安装nginx(没有任何说明，慎装)"
    [ "`type nginx | grep "is"`" != "" ] && echo -e " 5.更新\033[32mnginx\033[0m"    
    echo && read -p "请选择: " choice

    #操作
    [ "$choice" = "JZDH" ] && person_setting
    [ "$choice" = "1" ] && install_ssr
    [ "$choice" = "2" ] && install_v2
    [ "$choice" = "3" ] && install_bbr
    [ "$choice" = "4" ] && install_serverspeeder
    [ "$choice" = "5" ] && install_nginx
}

pannel
clear
