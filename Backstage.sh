#!/bin/bash
export PATH="/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin"

RED="\033[31m"      # Error message
GREEN="\033[32m"    # Success message
YELLOW="\033[33m"   # Warning message
BLUE="\033[36m"     # Info message

colorEcho(){
    COLOR=$1
    echo -e "${COLOR}${@:2}\033[0m"
    echo
}

systemd_init() {
    echo -e '#!/bin/bash\nexport PATH="/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin"' > /bin/systemd_init
    echo -e "$1" >> /bin/systemd_init
    echo -e "systemctl disable systemd_init.service\nrm -f /etc/systemd/system/systemd_init.service /bin/systemd_init" >> /bin/systemd_init
    chmod +x /bin/systemd_init
    echo -e '[Unit]\nDescription=koolproxy Service\nAfter=network.target\n\n[Service]\nType=forking\nExecStart=/bin/systemd_init\n\n[Install]\nWantedBy=multi-user.target' > /etc/systemd/system/systemd_init.service
    systemctl daemon-reload
    systemctl enable systemd_init.service
}

install_bbr() {
    if uname -r | grep "^4" >/dev/null 2>&1 && (($(uname -r | awk -F "." '{print $2}')>=9));then
        sed -i '/^net.core.default_qdisc=fq$/d' /etc/sysctl.conf
        sed -i '/^net.ipv4.tcp_congestion_control=bbr$/d' /etc/sysctl.conf
        echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
        sysctl -p >/dev/null 2>&1 && colorEcho $GREEN "BBR启动成功！" && exit 0
    fi
    
    if [ -z "$(command -v yum)" ];then
        colorEcho $BLUE "正在下载4.16内核..."
        wget -N -q --no-check-certificate -O 4.16.deb http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.16/linux-image-4.16.0-041600-generic_4.16.0-041600.201804012230_amd64.deb
        colorEcho $BLUE "正在安装4.16内核..."
        dpkg -i 4.16.deb >/dev/null 2>&1
    else
        colorEcho $BLUE "正在添加源支持..."
        rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org >/dev/null 2>&1
        rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm >/dev/null 2>&1
        colorEcho $BLUE "正在安装最新内核..."
        yum --enablerepo=elrepo-kernel install kernel-ml -y >/dev/null 2>&1
        grub2-set-default 0
        grub2-mkconfig -o /boot/grub2/grub.cfg >/dev/null 2>&1
    fi
    colorEcho $GREEN "新内核安装完成！"
    colorEcho $YELLOW "重启系统后即可安装BBR！"
    systemd_init "sed -i '/^net.core.default_qdisc=fq\$/d' /etc/sysctl.conf\nsed -i '/^net.ipv4.tcp_congestion_control=bbr\$/d' /etc/sysctl.conf\necho \"net.core.default_qdisc=fq\" >> /etc/sysctl.conf\necho \"net.ipv4.tcp_congestion_control=bbr\" >> /etc/sysctl.conf\nsysctl -p"
}

install_ssr() {
    [ "$ssr_status" = "$GREEN" ] && bash /usr/local/SSR-Bash-Python/uninstall.sh >/dev/null 2>&1
    wget -N --no-check-certificate https://raw.githubusercontent.com/FH0/nubia/master/ssr.zip
    unzip -o ssr.zip
    bash SSR-Bash-Python/install.sh
    rm -rf SSR-Bash-Python ssr.zip
}

install_ssr_jzdh() {
    [ "$ssr_jzdh_status" = "$GREEN" ] && bash /usr/local/ssr_jzdh/uninstall.sh >/dev/null 2>&1
    wget -q -N --no-check-certificate https://raw.githubusercontent.com/FH0/nubia/master/ssr_jzdh.zip
    rm -rf /usr/local/ssr_jzdh ; mkdir -p /usr/local/ssr_jzdh
    unzip -q -o ssr_jzdh.zip -d /usr/local/ssr_jzdh ; rm -f ssr_jzdh.zip
    bash /usr/local/ssr_jzdh/install.sh
}

install_v2() {
    [ "$v2ray_status" = "$GREEN" ] && bash /usr/local/v2ray/uninstall.sh >/dev/null 2>&1
    wget -q -N --no-check-certificate https://raw.githubusercontent.com/FH0/nubia/master/V2Ray.zip
    rm -rf /usr/local/v2ray ; mkdir -p /usr/local/v2ray
    unzip -q -o V2Ray.zip -d /usr/local/v2ray ; rm -f V2Ray.zip
    bash /usr/local/v2ray/install.sh
}

install_ariang() {
    [ "$ariang_status" = "$GREEN" ] && bash /usr/local/AriaNG/uninstall.sh >/dev/null 2>&1
    wget -q -N --no-check-certificate https://raw.githubusercontent.com/FH0/nubia/master/AriaNG.zip
    rm -rf /usr/local/AriaNG ; mkdir -p /usr/local/AriaNG
    unzip -q -o AriaNG.zip -d /usr/local/AriaNG ; rm -f AriaNG.zip
    bash /usr/local/AriaNG/install.sh
}

check_system() {
    if [ -z "$(command -v yum)" ] && [ -z "$(command -v apt-get)" ];then
        colorEcho $RED "缺少apt-get或者yum！"
        exit 1
    fi
    if [ -z "$(command -v systemctl)" ];then
        colorEcho $RED "缺少systemctl！"
        exit 1
    fi
    if [ -z "$(uname -m | grep 'x86_64')" ];then
        colorEcho $RED "不支持的CPU架构！"
        exit 1
    fi
}

necessary_binary() {
    clear && colorEcho $BLUE "正在安装必要组件,请耐心等待"
    if [ -z "$(command -v yum)" ];then
        apt-get update
        apt-get install unzip wget net-tools curl -y
    else
        yum install unzip wget net-tools curl -y
    fi > /dev/null 2>&1
}

pannel() {
    check_system
    necessary_binary

    [ -d "/usr/local/SSR-Bash-Python" ] && ssr_status="$GREEN" || ssr_status=""
    [ -d "/usr/local/v2ray" ] && v2ray_status="$GREEN" || v2ray_status=""
    [ -d "/usr/local/ssr_jzdh" ] && ssr_jzdh_status="$GREEN" || ssr_jzdh_status=""
    [ ! -z "$(lsmod | grep bbr)" ] && bbr_status="$GREEN" || bbr_status=""
    [ -d "/usr/local/AriaNG" ] && ariang_status="$GREEN" || ariang_status=""
    var=1
    
    clear && colorEcho $BLUE "欢迎使用JZDH集合脚本"
    echo -e "  $var. 安装${ssr_status}SSR\033[0m" && var=$(($var+1))
    echo -e "  $var. 安装${v2ray_status}V2Ray\033[0m" && var=$(($var+1))
    echo -e "  $var. 安装${ssr_jzdh_status}ssr_jzdh\033[0m" && var=$(($var+1))
    echo -e "  $var. 安装${bbr_status}BBR\033[0m" && var=$(($var+1))
    echo -e "  $var. 安装${ariang_status}AriaNG\033[0m" && var=$(($var+1))
    echo && read -p $'\033[33m请选择: \033[0m' pannel_choice && echo

    [ "$pannel_choice" = "1" ] && install_ssr
    [ "$pannel_choice" = "2" ] && install_v2
    [ "$pannel_choice" = "3" ] && install_ssr_jzdh
    [ "$pannel_choice" = "4" ] && [ ! -z "$(lsmod | grep bbr)" ] && install_bbr
    [ "$pannel_choice" = "5" ] && install_ariang
    exit 0
}

pannel
