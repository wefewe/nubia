#!/bin/bash
export PATH="/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin"

install_v2ray() {
    linux_digits=32
    [ -d "/lib64" ] && linux_digits=64
    mkdir /bin/v2ray
    v2ray_version_default=3.35
    {
        cd /bin/v2ray
        wget -q -N --no-check-certificate https://raw.githubusercontent.com/FH0/nubia/master/V2Ray.zip
        unzip -q V2Ray.zip
        cp /bin/v2ray/*.service /etc/systemd/system
        rm -f V2Ray.zip
        cp koolproxy /bin
        chmod +x /bin/koolproxy
    } > /dev/null 2>&1 &
clear
echo "检测到系统未安装V2Ray，请根据提示进行安装"
echo
read -p "请输入V2Ray版本[默认${v2ray_version_default}]: " v2ray_version
echo
if [ -z "$v2ray_version" ];then
    echo -e "已选择 \033[33m${v2ray_version_default}\033[0m 版本"
    echo
    v2ray_version=3.35
fi
{
    cd /bin/v2ray
    wget -q -N -P v2ray_download --no-check-certificate https://github.com/v2ray/v2ray-core/releases/download/v${v2ray_version}/v2ray-linux-${linux_digits}.zip
    cd v2ray_download
    unzip -q v2ray-linux-${linux_digits}.zip
    rm -f v2ray-linux-${linux_digits}.zip
    cp */v2ctl /bin/v2ray
    cp */v2ray /bin/v2ray
    cd ..
    rm -rf v2ray_download
} > /dev/null 2>&1 &
read -p "请设置端口[默认80][每两个端口之间用一个空格隔开]: " v2ray_port
echo
if [ -z "$v2ray_port" ];then
    echo -e "已设置端口 \033[33m80\033[0m"
    echo
    v2ray_port=80
fi
for E in ${v2ray_port};do
    v2ray_uuid=""
    echo "$E" >> /bin/v2ray/v2ray.ini
    read -p "请设置 ${E} 端口UUID[留空回车随机设置]: " v2ray_uuid
    echo
    if [ -z "$v2ray_uuid" ];then
        v2ray_uuid=$(cat /proc/sys/kernel/random/uuid)
        echo -e "已设置 \033[33m${E}\033[0m 端口UUID为\033[33m${v2ray_uuid}\033[0m"
        echo
    fi
    echo "$v2ray_uuid" >> /bin/v2ray/v2ray.ini
done
v2ray_config_reload
echo "设置完毕，正在安装"
wait
chmod 777 -R /bin/v2ray
systemctl start v2ray.service
curl -s https://raw.githubusercontent.com/FH0/nubia/master/V2Ray.sh > /bin/v2
chmod +x /bin/v2
vps_information=$(curl -s https://api.myip.com/)
echo $vps_information | grep -Eo '[0-9].*[0-9]' > /bin/v2ray/JZDH.txt
echo $vps_information | awk -F '"cc":"' '{print $2}' | awk -F '"' '{print $1}' >> /bin/v2ray/JZDH.txt
#定时缓存IP信息
echo '* * * * * /bin/v2 get' > /bin/v2ray/crontab.txt
crontab /bin/v2ray/crontab.txt
clear
pannel
}

v2ray_config_reload() {
    v2ray_config_line=$(cat /bin/v2ray/v2ray.ini | wc -l)
    if [ "$v2ray_config_line" = "2" ];then
        echo -e '{\n  "inbound": {\n    "port": '$(sed -n "1p" /bin/v2ray/v2ray.ini)',\n    "protocol": "vmess",\n    "settings": {\n      "clients": [\n        {\n          "id": "'$(sed -n "2p" /bin/v2ray/v2ray.ini)'",\n          "alterId": 100\n        }\n      ]\n    },\n    "streamSettings": {\n      "network": "tcp",\n      "tcpSettings": {\n        "header": {\n          "type": "http",\n          "response": {\n            "version": "1.1",\n            "status": "200",\n            "reason": "OK",\n            "headers": {\n              "Content-Type": [\n                "application/octet-stream",\n                "application/x-msdownload",\n                "text/html",\n                "application/x-shockwave-flash"\n              ],\n              "Connection": [\n                "keep-alive"\n              ]\n            }\n          }\n        }\n      }\n    }\n  },\n  "outbound": {\n    "protocol": "freedom",\n    "settings": {}\n  }\n}' > /bin/v2ray/config.json
    elif (("$v2ray_config_line" > "2"));then
        echo -e '{\n  "inbound": {\n    "port": '$(sed -n "1p" /bin/v2ray/v2ray.ini)',\n    "protocol": "vmess",\n    "settings": {\n      "clients": [\n        {\n          "id": "'$(sed -n "2p" /bin/v2ray/v2ray.ini)'",\n          "alterId": 100\n        }\n      ]\n    },\n    "streamSettings": {\n      "network": "tcp",\n      "tcpSettings": {\n        "header": {\n          "type": "http",\n          "response": {\n            "version": "1.1",\n            "status": "200",\n            "reason": "OK",\n            "headers": {\n              "Content-Type": [\n                "application/octet-stream",\n                "application/x-msdownload",\n                "text/html",\n                "application/x-shockwave-flash"\n              ],\n              "Connection": [\n                "keep-alive"\n              ]\n            }\n          }\n        }\n      }\n    }\n  },\n  "inboundDetour": [' > /bin/v2ray/config.json
        v2ray_ports=$(grep "^[0-9][0-9]*$" /bin/v2ray/v2ray.ini | sed '1d')
        for N in ${v2ray_ports};do
            v2ray_uuid_line=$(($(grep -n "^${N}$" /bin/v2ray/v2ray.ini | awk -F ":" '{print $1}')+1))
            v2ray_uuid=$(sed -n "${v2ray_uuid_line}p" /bin/v2ray/v2ray.ini)
            echo -e '    {\n      "port": '$N',\n      "protocol": "vmess",\n      "settings": {\n        "clients": [\n          {\n            "id": "'$v2ray_uuid'",\n            "alterId": 100\n          }\n        ]\n      },\n      "streamSettings": {\n        "network": "tcp",\n        "tcpSettings": {\n          "header": {\n            "type": "http",\n            "response": {\n              "version": "1.1",\n              "status": "200",\n              "reason": "OK",\n              "headers": {\n                "Content-Type": [\n                  "application/octet-stream",\n                  "application/x-msdownload",\n                  "text/html",\n                  "application/x-shockwave-flash"\n                ],\n                "Connection": [\n                  "keep-alive"\n                ]\n              }\n            }\n          }\n        }\n      }\n    },' >> /bin/v2ray/config.json
        done
        echo -e '  ],\n  "outbound": {\n    "protocol": "freedom",\n    "settings": {}\n  }\n}' >> /bin/v2ray/config.json
        sed -i ':a;N;$!ba;s|,\n  \]|\n  \]|' /bin/v2ray/config.json
    fi
}

uninstall_v2ray() {
    echo && echo "回车继续"
    read
    systemctl stop v2ray.service
    systemctl disable v2ray.service
    systemctl stop koolproxy.service
    systemctl disable koolproxy.service
    systemctl stop DNS.service
    systemctl disable DNS.service
    rm -rf /bin/v2ray
    rm -f /etc/systemd/system/v2ray.service
    rm -f /bin/v2
    rm -f /etc/systemd/system/DNS.service
    rm -f /etc/systemd/system/koolproxy.service
    rm -f /bin/koolproxy
    clear
    echo " V2Ray已停止并且已卸载"
    echo
}

update_v2ray() {
    linux_digits=32
    [ -d "/lib64" ] && linux_digits=64
    echo
    read -p "请输入V2Ray版本:" v2ray_version
    [ -z "$v2ray_version" ] && clear && pannel
    echo
    echo "将下载V2Ray版本[${v2ray_version}][${linux_digits}位]"
    echo
    mkdir -p v2ray_download
    wget -q -N -P v2ray_download --no-check-certificate https://github.com/v2ray/v2ray-core/releases/download/v${v2ray_version}/v2ray-linux-${linux_digits}.zip
    if [ "$?" != "0" ];then
        clear
        echo "未知原因导致下载失败，请重试！"
        echo
        exit
    fi
    cd v2ray_download
    echo "正在解压v2ray-linux-${linux_digits}.zip"
    unzip -q v2ray-linux-${linux_digits}.zip
    rm -f v2ray-linux-${linux_digits}.zip
    rm -f /bin/v2ray/v2ray
    rm -f /bin/v2ray/v2ctl
    cp */v2ctl /bin/v2ray
    cp */v2ray /bin/v2ray
    chmod 777 -R /bin/v2ray
    cd ..
    rm -rf v2ray_download
    systemctl restart v2ray.service
    systemctl enable v2ray.service > /dev/null 2>&1
    sleep 0.8
    clear
    pannel
}

bbr_settings() {
    if [ -z "$(lsmod | grep bbr)" ];then
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
            clear && echo 'BBR安装完成，需要重启系统生效'
            echo
        fi
    else
        sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
        sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
        sysctl -p
        clear && echo "BBR已关闭，需要重启系统生效"
        echo
    fi
    pannel
}

dns_settings() {
    if [ -f "/bin/v2ray/dnsmasq" ];then
        if [ -z "$(pgrep dnsmasq)" ];then
            systemctl start DNS.service
            systemctl enable DNS.service
        else
            systemctl stop DNS.service
            systemctl disable DNS.service
        fi
    else
        apt-get install dnsmasq -y
        yum install dnsmasq -y
        cp $(which dnsmasq) /bin/v2ray
        apt-get remove dnsmasq -y
        yum remove dnsmasq -y
        chmod +x /bin/v2ray/dnsmasq
        systemctl start DNS.service
        systemctl enable DNS.service
    fi > /dev/null 2>&1
    sleep 0.8
    clear
    pannel
}

koolproxy_settings() {
    useradd koolproxy_i386 > /dev/null 2>&1
    if [ -z "$(pgrep koolproxy_i386)" ];then
        systemctl start koolproxy.service
        systemctl enable koolproxy.service
    else
        systemctl stop koolproxy.service
        systemctl disable koolproxy.service
    fi > /dev/null 2>&1
    sleep 0.8
    clear
    pannel
}

v2ray_systemctl(){
    if [ "$1" = "1" ];then
        if [ "$(pgrep v2ray)" = "" ];then
            systemctl start v2ray.service
            systemctl enable v2ray.service
        else
            systemctl stop v2ray.service
            systemctl disable v2ray.service
        fi
    elif [ "$1" = "2" ];then
        systemctl restart v2ray.service
        systemctl enable v2ray.service
    fi > /dev/null 2>&1
    sleep 0.8
    clear
    pannel
}

get_ip_information() {
    local_ip=$(ip addr | grep -Eo "inet[ ]*[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | grep -v "127.0.0.1" | grep -Eo "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*")
    awk_ports=$(grep -Eo "^[0-9][0-9]*$" /bin/v2ray/v2ray.ini | sed 's|^|\:|g;s|$|\$|g' | tr "\n" "|" | sed 's|\|$||')
    connection_total=$(netstat -anp | grep "^tcp.*ESTABLISHED" | awk '{if($4~/('$awk_ports')/)print $5}' | grep -Eo "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | sort -u | wc -l)
    if [ "$connection_total" = "0" ];then
        exit 0
    else
        port=$(grep -Eo "^[0-9][0-9]*$" /bin/v2ray/v2ray.ini)
        for L in ${port};do
            connection_list=$(netstat -anp | grep "^tcp.*ESTABLISHED" | grep "${local_ip}:${L} " | awk '{print $5}' | grep -Eo "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | sort -u)
            for X in ${connection_list};do
                if [ -z "$(grep "${X} " /bin/v2ray/JZDH.txt)" ];then
                    ip_information=$(curl -s 'http://freeapi.ipip.net/'$X'' | sed 's/[[:punct:]]//g')
                    while [ -z ''${ip_information}'' ];do
                        ip_information=$(curl -s 'http://freeapi.ipip.net/'$X'' | sed 's/[[:punct:]]//g')
                        sleep 0.3
                    done
                    echo "${X} ${ip_information}" >> /bin/v2ray/JZDH.txt
                fi
            done
        done
    fi
}

get_v2ray_config() {
    v2ray_ports=$(grep "^[0-9][0-9]*$" /bin/v2ray/v2ray.ini)
    var=1
    echo
    for S in ${v2ray_ports};do
        echo -e " \033[32m${var}.\033[0m 查看 \033[33m${S}\033[0m 端口详细配置"
        var=$((${var}+1))
    done
    echo
    read -p "请选择: " config_choice
    echo
    [ -z "$config_choice" ] && clear && pannel
    port_select=$(sed -n ''$((${config_choice}*2-1))'p' /bin/v2ray/v2ray.ini)
    port_select_uuid=$(sed -n ''$((${config_choice}*2))'p' /bin/v2ray/v2ray.ini)
    v2rayNG=$(echo '{"add":"'$public_ip'","aid":"100","host":"k.youku.com","id":"'$port_select_uuid'","net":"tcp","path":"","port":"'$port_select'","ps":"'$City'","tls":"","type":"http","v":"2"}' | base64 | sed ':a;N;$!ba;s|\n||g' | sed 's|^|vmess://|g')
    echo -e "v2rayNG: \033[33m${v2rayNG}\033[0m"
    echo
    echo -e "服务IP:   \033[33m${public_ip}\033[0m"
    echo -e "服务端口: \033[33m${port_select}\033[0m"
    echo -e "用户ID:   \033[33m${port_select_uuid}\033[0m"
    echo -e "额外ID:   \033[33m100\033[0m"
    echo -e "加密方式: \033[33m任意选择\033[0m"
    echo -e "传输协议: \033[33mtcp\033[0m"
    echo -e "伪装类型: \033[33mhttp\033[0m"
    echo
    exit 0
}

port_setting() {
    v2ray_ports=$(grep "^[0-9][0-9]*$" /bin/v2ray/v2ray.ini)
    var=1
    echo
    echo -e "  \033[32m1.\033[0m 添加端口"
    echo -e "  \033[32m2.\033[0m 删除端口"
    echo -e "  \033[32m3.\033[0m 更改端口UUID"
    echo
    read -p "请选择: " port_setting_choice
    [ -z "$port_setting_choice" ] && clear && pannel
    echo
    if [ "$port_setting_choice" = "1" ];then
        read -p "请输入端口[每两个端口之间用一个空格隔开]: " v2ray_port
        [ -z "$v2ray_port" ] && port_setting
        echo
        for E in ${v2ray_port};do
            v2ray_uuid=""
            echo "$E" >> /bin/v2ray/v2ray.ini
            read -p "请输入 ${E} 端口UUID[留空回车随机设置]: " v2ray_uuid
            echo
            if [ -z "$v2ray_uuid" ];then
                v2ray_uuid=$(cat /proc/sys/kernel/random/uuid)
                echo -e "已设置 \033[33m${E}\033[0m 端口UUID为\033[33m${v2ray_uuid}\033[0m"
                echo
            fi
            echo "$v2ray_uuid" >> /bin/v2ray/v2ray.ini
        done
    elif [ "$port_setting_choice" = "2" ];then
        [ -z "$v2ray_ports" ] && port_setting
        for S in ${v2ray_ports};do
            echo -e " \033[32m${var}.\033[0m 删除 \033[33m${S}\033[0m 端口"
            var=$((${var}+1))
        done
        echo
        read -p "请选择: " del_port_choice
        [ -z "$del_port_choice" ] && port_setting
        echo
        echo "回车继续"
        read
        sed -i ''$((${del_port_choice}*2-1))'d' /bin/v2ray/v2ray.ini
        sed -i ''$((${del_port_choice}*2-1))'d' /bin/v2ray/v2ray.ini
    elif [ "$port_setting_choice" = "3" ];then
        for S in ${v2ray_ports};do
            echo -e " \033[32m${var}.\033[0m 更改 \033[33m${S}\033[0m 端口UUID"
            var=$((${var}+1))
        done
        echo
        read -p "请选择: " uuid_choice
        echo
        [ -z "$uuid_choice" ] && port_setting
        port_select=$(sed -n ''$((${uuid_choice}*2-1))'p' /bin/v2ray/v2ray.ini)
        read -p "请输入 ${port_select} 端口UUID[留空回车随机设置]: " v2ray_uuid
        echo
        if [ -z "$v2ray_uuid" ];then
            v2ray_uuid=$(cat /proc/sys/kernel/random/uuid)
            echo -e "已设置 \033[33m${port_select}\033[0m 端口UUID为\033[33m${v2ray_uuid}\033[0m"
            echo
        fi
        sed -i ''$((${uuid_choice}*2))'s|.*|'$v2ray_uuid'|' /bin/v2ray/v2ray.ini
    fi
    v2ray_config_reload
    if [ ! -z "$(pgrep v2ray)" ];then
        systemctl restart v2ray.service
        sleep 0.8
    fi
    port_setting
}

connection_info() {
    clear
    if [ "$connection_total" = "0" ];then
        pannel
    else
        port=$(grep -Eo "^[0-9][0-9]*$" /bin/v2ray/v2ray.ini)
        for L in ${port};do
            echo "${L}端口："
            connection_list=$(netstat -anp | grep "^tcp.*ESTABLISHED" | grep "${local_ip}:${L} " | awk '{print $5}' | grep -Eo "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | sort -u)
            for X in ${connection_list};do
                if [ -z "$(grep "${X} " /bin/v2ray/JZDH.txt)" ];then
                    ip_information=$(curl -s 'http://freeapi.ipip.net/'$X'' | sed 's/[[:punct:]]//g')
                    while [ -z ''${ip_information}'' ];do
                        ip_information=$(curl -s 'http://freeapi.ipip.net/'$X'' | sed 's/[[:punct:]]//g')
                        sleep 0.3
                    done
                    echo "${X} ${ip_information}" >> /bin/v2ray/JZDH.txt
                else
                    ip_information=$(grep "$X" /bin/v2ray/JZDH.txt | awk '{print $2}')
                fi
                printf "  \033[33m%-20s %-20s\033[0m\n" ${X} ${ip_information}
            done
            echo
        done
        pannel
    fi
}

pannel() {
    v2ray_status=停止
    [ -z "$(pgrep v2ray)" ] && v2ray_status=启动
    bbr_status=关闭
    [ -z "$(lsmod | grep bbr)" ] && bbr_status=启动
    koolproxy_status=停止
    [ -z "$(pgrep koolproxy_i386)" ] && koolproxy_status=启动
    v2ray_version=$(/bin/v2ray/v2ray --version | sed -n "1p" | awk '{print $2}' | sed 's/.\(.*\)/\1/g')
    local_ip=$(ip addr | grep -Eo "inet[ ]*[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | grep -v "127.0.0.1" | grep -Eo "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*")
    awk_ports=$(grep -Eo "^[0-9][0-9]*$" /bin/v2ray/v2ray.ini | sed 's|^|\:|g;s|$|\$|g' | tr "\n" "|" | sed 's|\|$||')
    connection_total=$(netstat -anp | grep "^tcp.*ESTABLISHED" | awk '{if($4~/('$awk_ports')/)print $5}' | grep -Eo "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | sort -u | wc -l)
    public_ip=$(cat /bin/v2ray/JZDH.txt | sed -n '1p')
    City=$(cat /bin/v2ray/JZDH.txt | sed -n '2p')
    v2ray_ports=$(grep "^[0-9][0-9]*$" /bin/v2ray/v2ray.ini | tr "\n" " ")

    echo " V2Ray多功能脚本，欢迎使用"
    echo
    echo -e "  \033[32m1.\033[0m 更换V2Ray内核 \033[33m${v2ray_version}\033[0m"
    echo -e "  \033[32m2.\033[0m 重装V2Ray"
    echo -e "  \033[32m3.\033[0m 卸载V2Ray"
    echo "━━━━━━━━━━━━━━━━"
    echo -e "  \033[32m4.\033[0m 端口设置 \033[33m${v2ray_ports}\033[0m"
    echo -e "  \033[32m5.\033[0m 查看V2Ray客户端配置"
    echo -e "  \033[32m6.\033[0m 查看设备连接情况 \033[33m${connection_total}\033[0m"
    echo "━━━━━━━━━━━━━━━━"
    echo -e "  \033[32m7.\033[0m ${v2ray_status}V2Ray"
    echo -e "  \033[32m8.\033[0m 重启V2Ray"
    echo "━━━━━━━━━━━━━━━━"
    echo -e "  \033[32m9.\033[0m ${bbr_status}BBR加速"
    echo -e " \033[32m10.\033[0m ${koolproxy_status}koolproxy去广告"
    [ -z "$(pgrep dnsmasq)" ] || echo -e " \033[32m11.\033[0m 关闭去广告加速DNS  请设置DNS为 \033[33m${public_ip}\033[0m"
    [ -z "$(pgrep dnsmasq)" ] && echo -e " \033[32m11.\033[0m 开启去广告加速DNS"
    echo
    read -p "请选择: " pannel_choice
    [ "$pannel_choice" = "1" ] && update_v2ray
    [ "$pannel_choice" = "2" ] && (uninstall_v2ray;bash <(curl -sL https://raw.githubusercontent.com/FH0/nubia/master/V2Ray.sh))
    [ "$pannel_choice" = "3" ] && uninstall_v2ray && exit 0
    [ "$pannel_choice" = "4" ] && port_setting
    [ "$pannel_choice" = "5" ] && get_v2ray_config
    [ "$pannel_choice" = "6" ] && connection_info
    [ "$pannel_choice" = "7" ] && v2ray_systemctl 1
    [ "$pannel_choice" = "8" ] && v2ray_systemctl 2
    [ "$pannel_choice" = "9" ] && bbr_settings
    [ "$pannel_choice" = "10" ] && koolproxy_settings
    [ "$pannel_choice" = "11" ] && dns_settings
    clear && exit 0
}

if [ -z "$1" ];then
    if [ -d "/bin/v2ray" ];then
        clear && pannel
    else
        install_v2ray
    fi
else
    get_ip_information
fi
