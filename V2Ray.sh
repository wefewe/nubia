#!/bin/bash
export PATH="/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin"
wp="/bin/v2ray"

dl_pre() {
    mkdir -p $wp ; cd $wp
    wget -N --no-check-certificate https://raw.githubusercontent.com/FH0/nubia/master/V2Ray.zip
    unzip V2Ray.zip && rm -f V2Ray.zip
    cat v2ray.service > /lib/systemd/system/v2ray.service
    cat koolproxy.service > /lib/systemd/system/koolproxy.service
    systemctl daemon-reload
    
    v2ray_latest_version=$(curl -s https://github.com/v2ray/v2ray-core/releases/latest | grep -Eo 'v[0-9]\.[0-9][0-9]*')
    wget -N -P $wp --no-check-certificate https://github.com/v2ray/v2ray-core/releases/download/${v2ray_latest_version}/v2ray-linux-64.zip
    unzip -o v2ray-linux-64.zip */v2ray */v2ctl
    $(command -v cp) -f */v2ctl $wp ; $(command -v cp) -f */v2ray $wp
    rm -rf v2ray-linux-64.zip $(dirname */v2ray)
    echo "29815 $(cat /proc/sys/kernel/random/uuid)" > $wp/v2ray.ini
}

install_v2ray() {
    dl_pre
    chmod 777 -R $wp
    curl -s ifconfig.me | sed 's|^|##|' >> $0
        systemctl start v2ray ; systemctl enable v2ray
            clear
            pannel
        }

    v2ray_config_reload() {
        v2ray_config_line=$(cat $wp/v2ray.ini | wc -l)
        if [ "$v2ray_config_line" = "1" ];then
            echo -e '{\n  "inbound": {\n    "port": '$(sed -n "1p" $wp/v2ray.ini)',\n    "protocol": "vmess",\n    "settings": {\n      "clients": [\n        {\n          "id": "'$(sed -n "2p" $wp/v2ray.ini)'",\n          "alterId": 100\n        }\n      ]\n    },\n    "streamSettings": {\n      "network": "tcp",\n      "tcpSettings": {\n        "header": {\n          "type": "http",\n          "response": {\n            "version": "1.1",\n            "status": "200",\n            "reason": "OK",\n            "headers": {\n              "Content-Type": [\n                "application/octet-stream",\n                "application/x-msdownload",\n                "text/html",\n                "application/x-shockwave-flash"\n              ],\n              "Connection": [\n                "keep-alive"\n              ]\n            }\n          }\n        }\n      }\n    }\n  },\n  "outbound": {\n    "protocol": "freedom",\n    "settings": {}\n  }\n}' > $wp/config.json
        elif (("$v2ray_config_line" > "1"));then
            echo -e '{\n  "inbound": {\n    "port": '$(sed -n "1p" $wp/v2ray.ini)',\n    "protocol": "vmess",\n    "settings": {\n      "clients": [\n        {\n          "id": "'$(sed -n "2p" $wp/v2ray.ini)'",\n          "alterId": 100\n        }\n      ]\n    },\n    "streamSettings": {\n      "network": "tcp",\n      "tcpSettings": {\n        "header": {\n          "type": "http",\n          "response": {\n            "version": "1.1",\n            "status": "200",\n            "reason": "OK",\n            "headers": {\n              "Content-Type": [\n                "application/octet-stream",\n                "application/x-msdownload",\n                "text/html",\n                "application/x-shockwave-flash"\n              ],\n              "Connection": [\n                "keep-alive"\n              ]\n            }\n          }\n        }\n      }\n    }\n  },\n  "inboundDetour": [' > $wp/config.json
            v2ray_ports=$(grep -Eo "^[0-9]{1,5} " $wp/v2ray.ini)
            for N in ${v2ray_ports};do
                v2ray_uuid=$(sed -n "${v2ray_uuid_line}p" $wp/v2ray.ini)
                echo -e '    {\n      "port": '$N',\n      "protocol": "vmess",\n      "settings": {\n        "clients": [\n          {\n            "id": "'$v2ray_uuid'",\n            "alterId": 100\n          }\n        ]\n      },\n      "streamSettings": {\n        "network": "tcp",\n        "tcpSettings": {\n          "header": {\n            "type": "http",\n            "response": {\n              "version": "1.1",\n              "status": "200",\n              "reason": "OK",\n              "headers": {\n                "Content-Type": [\n                  "application/octet-stream",\n                  "application/x-msdownload",\n                  "text/html",\n                  "application/x-shockwave-flash"\n                ],\n                "Connection": [\n                  "keep-alive"\n                ]\n              }\n            }\n          }\n        }\n      }\n    },' >> $wp/config.json
            done
            echo -e '  ],\n  "outbound": {\n    "protocol": "freedom",\n    "settings": {}\n  }\n}' >> $wp/config.json
            sed -i ':a;N;$!ba;s|,\n  \]|\n  \]|' $wp/config.json
        fi
    }

uninstall_v2ray() {
    echo && echo "回车继续"
    read
    systemctl stop v2ray ; systemctl disable v2ray
    systemctl stop koolproxy ; systemctl disable koolproxy
    rm -rf $wp /bin/v2 /lib/systemd/system/koolproxy.service /lib/systemd/system/v2ray.service
    clear && echo " V2Ray已停止并且已卸载"
    echo
    exit 0
}

update_v2ray_core() {
    v2ray_latest_version=$(curl -s https://github.com/v2ray/v2ray-core/releases/latest | grep -Eo '[0-9]\.[0-9][0-9]*')
    echo
    echo -e "V2Ray最新核心为 \033[32m${v2ray_latest_version}\033[0m"
    echo
    read -p "请输入V2Ray版本:" v2ray_version
    [ -z "$v2ray_version" ] && clear && pannel
    echo
    wget -N -P $wp --no-check-certificate https://github.com/v2ray/v2ray-core/releases/download/v${v2ray_version}/v2ray-linux-64.zip
    unzip -o v2ray-linux-64.zip */v2ray */v2ctl
    $(command -v cp) -f */v2ctl $wp ; $(command -v cp) -f */v2ray $wp
    rm -rf v2ray-linux-64.zip $(dirname */v2ray)
    chmod 777 -R $wp
    [ ! -z "$(pgrep v2ray)" ] && systemctl restart v2ray
    sleep 0.8 ; clear ; pannel
}

bbr_settings() {
    if (("$(uname -r | grep -Eo '^.')" > 3));then
        if [ -z "$(grep 'net.core.default_qdisc' /etc/sysctl.conf)" ];then
            echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
            echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
            sysctl -p
            clear
        else
            sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
            sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
            clear && echo "BBR已关闭，需要重启系统后生效"
            echo
        fi
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
        systemctl daemon-reload
        systemctl enable rc-local
        systemctl start rc-local.service
        clear && echo 'BBR安装完成，需要重启系统生效'
        echo
    fi
    pannel
}

koolproxy_settings() {
    if [ -z "$(pgrep koolproxy)" ];then
            systemctl start koolproxy ; systemctl enable koolproxy
        else
            systemctl stop koolproxy ; systemctl disable koolproxy
    fi > /dev/null 2>&1
    sleep 0.8 ; clear ; pannel
}

v2ray_on_off(){
    if [ "$1" = "1" ];then
        if [ -z "$(pgrep v2ray)" ];then
            systemctl start v2ray ; systemctl enable v2ray
        else
            systemctl stop v2ray ; systemctl disable v2ray
        fi
    elif [ "$1" = "2" ];then
        systemctl restart v2ray ; systemctl enable v2ray
    fi > /dev/null 2>&1
    sleep 0.8 ; clear ; pannel
}

get_v2ray_config() {
    v2ray_ports=$(grep -Eo "^[0-9]{1,5} " $wp/v2ray.ini)
    public_ip=$(grep "^##" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}')
    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    for K in ${v2ray_ports};do
        v2ray_uuid=$(grep "$K " $wp/v2ray.ini | awk '{print $2}')
        v2rayNG=$(echo '{"add":"'$public_ip'","aid":"100","host":"k.youku.com","id":"'$v2ray_uuid'","net":"tcp","path":"","port":"'$K'","ps":"'$public_ip'","tls":"","type":"http","v":"2"}' | base64 | sed ':a;N;$!ba;s|\n||g' | sed 's|^|vmess://|')
        echo -e "v2rayNG: \033[33m${v2rayNG}\033[0m"
        echo
        echo -e "服务IP:   \033[33m${public_ip}\033[0m"
        echo -e "服务端口: \033[33m${K}\033[0m"
        echo -e "用户ID:   \033[33m${v2ray_uuid}\033[0m"
        echo -e "额外ID:   \033[33m100\033[0m"
        echo -e "加密方式: \033[33m任意选择\033[0m"
        echo -e "传输协议: \033[33mtcp\033[0m"
        echo -e "伪装类型: \033[33mhttp\033[0m"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    done
    exit 0
}

ports_setting() {
    v2ray_ports=$(grep -Eo "^[0-9]{1,5} " $wp/v2ray.ini)
    var=1
    echo
    echo -e "  \033[32m1.\033[0m 添加端口"
    echo -e "  \033[32m2.\033[0m 删除端口"
    echo -e "  \033[32m3.\033[0m 更改端口UUID"
    echo
    read -p "请选择: " ports_setting_choice
    [ -z "$port_setting_choice" ] && clear && pannel
    echo
    if [ "$port_setting_choice" = "1" ];then
        read -p "请输入端口[每两个端口之间用一个空格隔开]: " v2ray_port
        [ -z "$v2ray_port" ] && ports_setting
        echo
        for E in ${v2ray_port};do
            v2ray_uuid=
            read -p "请输入 ${E} 端口UUID[留空回车随机设置]: " v2ray_uuid
            echo
            if [ -z "$v2ray_uuid" ];then
                v2ray_uuid=$(cat /proc/sys/kernel/random/uuid)
                echo -e "已设置 \033[33m${E}\033[0m 端口UUID为 \033[33m${v2ray_uuid}\033[0m"
                echo
            fi
            echo "$E $v2ray_uuid" >> $wp/v2ray.ini
        done
    elif [ "$port_setting_choice" = "2" ];then
        [ -z "$v2ray_ports" ] && ports_setting
        for S in ${v2ray_ports};do
            echo -e " \033[32m${var}.\033[0m 删除 \033[33m${S}\033[0m 端口"
            var=$(($var+1))
        done
        echo
        read -p "请选择: " del_port_choice
        [ -z "$del_port_choice" ] && ports_setting
        echo
        echo "回车继续"
        read
        sed -i "${del_port_choice}d" $wp/v2ray.ini
    elif [ "$port_setting_choice" = "3" ];then
        for S in ${v2ray_ports};do
            echo -e " \033[32m${var}.\033[0m 更改 \033[33m${S}\033[0m 端口UUID"
            var=$(($var+1))
        done
        echo
        read -p "请选择: " uuid_choice
        echo
        [ -z "$uuid_choice" ] && ports_setting
        port_select=$(sed -n "${uuid_choice}p" $wp/v2ray.ini | awk '{print $1}')
        read -p "请输入 ${port_select} 端口UUID[留空回车随机设置]: " v2ray_uuid
        echo
        if [ -z "$v2ray_uuid" ];then
            v2ray_uuid=$(cat /proc/sys/kernel/random/uuid)
            echo -e "已设置 \033[33m${port_select}\033[0m 端口UUID为\033[33m${v2ray_uuid}\033[0m"
            echo
        fi
        sed -i "s|${port_select} .*|${port_select} $v2ray_uuid|" $wp/v2ray.ini
    fi
    v2ray_config_reload
    [ ! -z "$(pgrep v2ray)" ] && systemctl restart v2ray
    ports_setting
}

show_connections() {
    awk_ports=$(grep -Eo "^[0-9][0-9]*$" $wp/v2ray.ini | sed 's|^|\:|g;s|$|\$|g' | tr "\n" "|" | sed 's|\|$||')
    connection_ip=$(netstat -anp | grep "^tcp.*ESTABLISHED" | awk '{if($4~/('$awk_ports')/)print $5}' | grep -Eo "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | sort -u)
    clear
    v2ray_ports=$(grep -Eo "^[0-9]{1,5} " $wp/v2ray.ini)
    for L in ${v2ray_ports};do
        echo "${L}端口："
        connection_ip=$(netstat -anp | grep "^tcp.*ESTABLISHED" | awk '{if($4~/:'$L'$/)print $5}' | grep -Eo "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | sort -u)
        for X in ${connection_ip};do
            echo -e "  \033[33m${X}\033[0m"
        done
        echo
    done
    pannel
}

pannel() {
    [ -z "$(pgrep v2ray)" ] && v2ray_status=启动 || v2ray_status=停止
    [ -z "$(lsmod | grep bbr)" ] && bbr_status=启动 || bbr_status=关闭
    [ -z "$(pgrep koolproxy)" ] && koolproxy_status=启动 || koolproxy_status=停止
    v2ray_version=$($wp/v2ray --version | sed -n "1p" | awk '{print $2}' | sed 's/.\(.*\)/\1/g')
    awk_ports=$(grep -Eo "^[0-9][0-9]*$" $wp/v2ray.ini | sed 's|^|\:|g;s|$|\$|g' | tr "\n" "|" | sed 's|\|$||')
    connection_total=$(netstat -anp | grep "^tcp.*ESTABLISHED" | awk '{if($4~/('$awk_ports')/)print $5}' | grep -Eo "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | sort -u | wc -l)
    v2ray_ports=$(grep "^[0-9][0-9]*$" $wp/v2ray.ini | tr "\n" " ")

    echo " V2Ray多功能脚本，欢迎使用"
    echo
    echo -e "\033[32m  1.\033[0m 更换V2Ray内核 \033[33m${v2ray_version}\033[0m"
    echo -e "\033[32m  2.\033[0m 重装V2Ray"
    echo -e "\033[32m  3.\033[0m 卸载V2Ray"
    echo "━━━━━━━━━━━━━━━━"
    echo -e "\033[32m  4.\033[0m 端口设置 \033[33m${v2ray_ports}\033[0m"
    echo -e "\033[32m  5.\033[0m 查看V2Ray客户端配置"
    echo -e "\033[32m  6.\033[0m 查看设备连接情况 \033[33m${connection_total}\033[0m"
    echo "━━━━━━━━━━━━━━━━"
    echo -e "\033[32m  7.\033[0m ${v2ray_status}V2Ray"
    echo -e "\033[32m  8.\033[0m 重启V2Ray"
    echo "━━━━━━━━━━━━━━━━"
    echo -e "\033[32m  9.\033[0m ${bbr_status}BBR加速"
    echo -e "\033[32m 10.\033[0m ${koolproxy_status}koolproxy去广告"
    echo
    read -p "请选择: " pannel_choice

    case $pannel_choice in
        1)
            update_v2ray_core
            ;;
        2)
            uninstall_v2ray
            curl -s https://raw.githubusercontent.com/FH0/nubia/master/V2Ray.sh > /bin/v2
            chmod +x /bin/v2 && v2
            ;;
        3)
            uninstall_v2ray
            ;;
        4)
            ports_setting
            ;;
        5)
            show_v2ray_config
            ;;
        6)
        [ "$connection_total" = "0" ] && pannel
            show_connections
            ;;
        7)
            v2ray_on_off 1
            ;;
        8)
            v2ray_on_off 2
            ;;
        9)
            bbr_setting
            ;;
        10)
            koolproxy_setting
            ;;
        *)
            clear && exit 1
            ;;
    esac
}

if [ -d "$wp" ];then
    clear && pannel
else
    install_v2ray
fi
