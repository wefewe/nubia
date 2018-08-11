#!/bin/bash
export PATH="/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin"

install_bbr() {
    if [ -f "/usr/bin/apt-get" ];then
        sed -i '/^net.core.default_qdisc=fq$/d' /etc/sysctl.conf
        sed -i '/^net.ipv4.tcp_congestion_control=bbr$/d' /etc/sysctl.conf
        echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
        sysctl -p
    else
        clear && echo '过程需要10分钟左右，部分场景会卡住，耐心等待'
        echo
        sleep 2
        yum update -y
        rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
        rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
        yum --enablerepo=elrepo-kernel install kernel-ml -y
        grub2-set-default 0
        echo -e '[Unit]\nDescription=/etc/rc.local\nConditionPathExists=/etc/rc.local\n\n[Service]\nType=forking\nExecStart=/etc/rc.local start\nTimeoutSec=0\nStandardOutput=tty\nRemainAfterExit=yes\nSysVStartPriority=99\n\n[Install]\nWantedBy=multi-user.target' > /etc/systemd/system/rc-local.service
        echo -e "#!/bin/bash\nsed -i '/^net.core.default_qdisc=fq$/d' /etc/sysctl.conf\nsed -i '/^net.ipv4.tcp_congestion_control=bbr$/d' /etc/sysctl.conf\necho 'net.core.default_qdisc=fq' >> /etc/sysctl.conf\necho 'net.ipv4.tcp_congestion_control=bbr' >> /etc/sysctl.conf\nsysctl -p\necho -e '#!/bin/sh -e\nexit 0' > /etc/rc.local\nexit 0" > /etc/rc.local
        chmod +x /etc/rc.local
        systemctl enable rc-local
        systemctl start rc-local.service
        clear && echo 'BBR安装完成，请重启系统'
    fi
}

install_ssr() {
    country=$(curl -sL http://ip-api.com/xml | grep "country")
    while [ "$country" = "" ];do
        country=$(curl -sL http://ip-api.com/xml | grep "country")
        sleep 0.5
    done
    zip=$(echo "$country" | grep "China")
    [ "$zip" = "" ] && wget -N --no-check-certificate https://raw.githubusercontent.com/FH0/nubia/master/ssr.zip
    [ "$zip" != "" ] && wget -N --no-check-certificate https://gitee.com/just1601/tiny-sh/raw/master/ssr.zip
    unzip -o ssr.zip
    bash SSR-Bash-Python/install.sh
    rm -rf SSR-Bash-Python
    rm -f ssr.zip
    ssr
}

install_v2() {
    bash <(curl -sL https://raw.githubusercontent.com/FH0/nubia/master/V2Ray.sh)
}

pannel() {
    clear && echo -e " 正在安装必要组件,请耐心等待"
    yum install unzip wget net-tools curl -y > /dev/null 2>&1
    apt-get install unzip wget net-tools curl -y > /dev/null 2>&1

    #用户选择
    clear && echo -e "欢迎使用 V2Ray/SSR 搭建脚本" && echo
    [ -d "/usr/local/SSR-Bash-Python" ] && echo -e " 1.重装\033[32mSSR\033[0m"
    [ ! -d "/usr/local/SSR-Bash-Python" ] && echo -e " 1.安装SSR(输入ssr进入管理面板)"
    [ -d "/bin/v2ray" ] && echo -e " 2.重装\033[32mV2Ray\033[0m"
    [ ! -d "/bin/v2ray" ] && echo -e " 2.安装V2Ray(输入v2进入管理面板)"
    echo
    [ "$(lsmod | grep bbr)" = "" ] && echo -e " 3.安装BBR"
    [ "$(lsmod | grep bbr)" != "" ] && echo -e " 3.重装\033[32mBBR\033[0m"
    echo && read -p "请选择: " choice

    #操作
    [ "$choice" = "1" ] && install_ssr
    [ "$choice" = "2" ] && install_v2
    [ "$choice" = "3" ] && install_bbr
    clear && exit 0
}

pannel
