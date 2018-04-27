#!/bin/bash
clear
echo " 正在安装必要组件,请耐心等待"
{
    yum install unzip wget net-tools curl -y
    apt-get install unzip wget net-tools curl -y
} > /dev/null 2>&1 

#用户选择
clear
echo "欢迎使用V2Ray&SSR搭建脚本"
echo 
echo " 1.安装SSR"
echo " 2.安装V2Ray"
echo
echo " 3.安装BBR(安装完成后自动重启系统)"
echo " 4.安装锐速(安装完成后自动重启系统)"
echo
read -p "请选择: " choice

#操作
if [ "$choice" = "1" ];then
    clear
    echo " 1.码云(国内平台)"
    echo  " 2.github(国外平台)"
    echo 
    read -p "请选择资源包托管平台: " zip
    if [ "$zip" = "1" ];then
        wget -N --no-check-certificate https://gitee.com/just1601/tiny-sh/raw/master/ssr.zip
    else
        wget -N --no-check-certificate https://raw.githubusercontent.com/FH0/nubia/master/ssr.zip
    fi
    unzip -o ssr.zip
    bash SSR-Bash-Python/install.sh
elif [ "$choice" = "2" ];then
    clear
    echo " 1.码云(国内平台)"
    echo  " 2.github(国外平台)"
    echo 
    read -p "请选择资源包托管平台: " zip
    if [ "$zip" = "1" ];then
        wget -N --no-check-certificate https://gitee.com/just1601/tiny-sh/raw/master/V2Ray.zip
    else
        wget -N --no-check-certificate https://raw.githubusercontent.com/FH0/nubia/master/V2Ray.zip
    fi
    unzip -o V2Ray.zip
    bash V2Ray/v2ray.sh
elif [ "$choice" = "3" ];then
    bash <(curl -L -s https://raw.githubusercontent.com/FH0/nubia/master/bbr.sh)
    reboot
elif [ "$choice" = "4" ];then
    bash <(curl -L -s https://raw.githubusercontent.com/FH0/nubia/master/serverspeeder.sh)
    reboot
fi
