#!/bin/bash

function centos_install {
    yum update -y
    rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
    rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
    yum --enablerepo=elrepo-kernel install kernel-ml -y
    grub2-set-default 0
    sed -i '/JZDH_bbr/d' /etc/rc.d/rc.local
    echo '/bin/JZDH_bbr' >> /etc/rc.d/rc.local
    chmod 0777 /etc/rc.d/rc.local
    rm -f /bin/JZDH_bbr
    echo -e 'sed -i '/net\.core\.default_qdisc=fq/d' /etc/sysctl.conf\nsed -i '/net\.ipv4\.tcp_congestion_control=bbr/d' /etc/sysctl.conf\necho "net.core.default_qdisc=fq" >> /etc/sysctl.conf\necho "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf\nsysctl -p\nsed -i '/JZDH_bbr/d' /etc/rc.d/rc.local\nrm -f \$0' > /bin/JZDH_bbr
    chmod +x /bin/JZDH_bbr
    reboot
}

function debian_bbr_start {
    sed -i '/net\.core\.default_qdisc=fq/d' /etc/sysctl.conf
    sed -i '/net\.ipv4\.tcp_congestion_control=bbr/d' /etc/sysctl.conf
    echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
    sysctl -p
}

function install_bbr {
    if [ "`cat /etc/*release | grep "CentOS"`" = "" ];then
        debian_bbr_start
    else
        centos_install
    fi
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
    [ ! -d "/bin/v2ray" ] && echo -e " 2.安装V2Ray(输入v2进入管理面板)"
    echo 
    [ "`lsmod | grep bbr`" = "" ] && echo -e " 3.安装BBR(安装完成后自动重启系统)"
    [ "`lsmod | grep bbr`" != "" ] && echo -e " 3.重装\033[32mBBR\033[0m"
    echo 
    [ -f '/usr/sbin/nginx' ] && echo -e " 4.更新\033[32mnginx\033[0m"    
    [ ! -f '/usr/sbin/nginx' ] && echo " 4.安装nginx(没有任何说明，慎装)"
    echo && read -p "请选择: " choice

    #操作
    [ "$choice" = "1" ] && install_ssr
    [ "$choice" = "2" ] && install_v2
    [ "$choice" = "3" ] && install_bbr
    [ "$choice" = "4" ] && install_nginx
}

pannel
clear
