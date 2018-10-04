#!/bin/bash
export PATH="/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin"

RED="31m"      # Error message
GREEN="32m"    # Success message
YELLOW="33m"   # Warning message
BLUE="36m"     # Info message

colorEcho(){
    COLOR=$1
    echo -e "\033[${COLOR}${@:2}\033[0m"
    echo
}

install_bbr() {
    if uname -r | grep "^4" >/dev/null 2>&1 && (($(uname -r | awk -F "." '{print $2}')>=9));then
        sed -i '/^net.core.default_qdisc=fq$/d' /etc/sysctl.conf
        sed -i '/^net.ipv4.tcp_congestion_control=bbr$/d' /etc/sysctl.conf
        echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
        sysctl -p >/dev/null 2>&1 && colorEcho $GREEN "BBR启动成功！" && exit 0
    fi

    if [ "$(uname -m)" = "x86_64" ];then
        VDIS=amd64
    elif [ "$(uname -m)" = "i686" ] || [ "$(uname -m)" = "i386" ];then
        VDIS=i386
    fi
    
    clear
    colorEcho $YELLOW "新内核安装后重启服务器，再次执行本脚本即可开启BBR"
    echo "  1. 32/64位 Debian8 Ubuntu14.04 Ubuntu16.04"
    echo "  2. 32/64位 CentOS7"
    echo "  3. 32/64位 CentOS6"
    echo
    read -p $'\033[33m请选择: \033[0m' kernel_choice && echo

    if [ "$kernel_choice" = "1" ];then
        colorEcho $BLUE "正在下载4.16内核..."
        wget -N -q --no-check-certificate -O 4.16.deb http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.16/linux-image-4.16.0-041600-generic_4.16.0-041600.201804012230_$VDIS.deb
        colorEcho $BLUE "正在安装4.16内核..."
        dpkg -i 4.16.deb >/dev/null 2>&1
        colorEcho $GREEN "新内核安装完成！"
    elif [ "$kernel_choice" = "2" ];then
        colorEcho $BLUE "正在添加源支持..."
        rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org >/dev/null 2>&1
        rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm >/dev/null 2>&1
        colorEcho $BLUE "正在安装最新内核..."
        yum --enablerepo=elrepo-kernel install kernel-ml -y >/dev/null 2>&1
        grub2-set-default 0
        grub2-mkconfig -o /boot/grub2/grub.cfg >/dev/null 2>&1
        colorEcho $GREEN "新内核安装完成！"
    elif [ "$kernel_choice" = "3" ];then
        colorEcho $BLUE "正在添加源支持..."
        rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org >/dev/null 2>&1
        rpm -Uvh http://www.elrepo.org/elrepo-release-6-8.el6.elrepo.noarch.rpm >/dev/null 2>&1
        colorEcho $BLUE "正在安装最新内核..."
        yum --enablerepo=elrepo-kernel install kernel-ml -y >/dev/null 2>&1
        sed -i 's|default=[0-9]*|default=0|' /boot/grub/grub.conf
        colorEcho $GREEN "新内核安装完成！"
    fi
}

install_ssr() {
    [ -d "/usr/local/SSR-Bash-Python" ] && bash /usr/local/SSR-Bash-Python/uninstall.sh >/dev/null 2>&1
    wget -N --no-check-certificate https://raw.githubusercontent.com/FH0/nubia/master/ssr.zip
    unzip -o ssr.zip
    bash SSR-Bash-Python/install.sh
    rm -rf SSR-Bash-Python ssr.zip
}

install_v2() {
    [ -d "/usr/local/v2ray" ] && bash /usr/local/v2ray/uninstall.sh >/dev/null 2>&1
    wget -q -N --no-check-certificate https://raw.githubusercontent.com/FH0/nubia/master/V2Ray.zip
    rm -rf /usr/local/v2ray ; mkdir -p /usr/local/v2ray
    unzip -q -o V2Ray.zip -d /usr/local/v2ray
    bash /usr/local/v2ray/install.sh
}

pannel() {
    clear && colorEcho $BLUE " 正在安装必要组件,请耐心等待"
    command -v yum >/dev/null 2>&1 && Installer=yum
    command -v apt-get >/dev/null 2>&1 && Installer=apt-get
    [ -z "$Installer" ] && colorEcho $RED "没有找到apt-get或者yum！" && exit 1
    $Installer install unzip wget net-tools curl -y > /dev/null 2>&1

    #用户选择
    clear && colorEcho $BLUE "欢迎使用 V2Ray/SSR 搭建脚本"
    [ -d "/usr/local/SSR-Bash-Python" ] && echo -e "  1. 重装\033[32mSSR\033[0m" || echo -e "  1. 安装SSR(输入ssr进入管理面板)"
    [ -d "/usr/local/v2ray" ] && echo -e "  2. 重装\033[32mV2Ray\033[0m" || echo -e "  2. 安装V2Ray(输入v2进入管理面板)"
    echo
    [ "$(lsmod | grep bbr)" = "" ] && echo -e "  3. 安装BBR" || echo -e "  3. \033[32mBBR\033[0m已启动"
    echo && read -p $'\033[33m请选择: \033[0m' pannel_choice && echo

    #操作
    [ "$pannel_choice" = "1" ] && install_ssr
    [ "$pannel_choice" = "2" ] && install_v2
    [ "$pannel_choice" = "3" ] && install_bbr
    exit 0
}

pannel
