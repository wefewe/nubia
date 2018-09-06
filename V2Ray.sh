#!/bin/bash
export PATH="/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin"
wp="/bin/v2ray"

install_v2ray() {
    linux_digits=32
    [ -d "/lib64" ] && linux_digits=64
    v2ray_version_default=3.38
    {
        mkdir ${wp}
        cd ${wp}
        wget -N --no-check-certificate https://raw.githubusercontent.com/FH0/nubia/master/V2Ray.zip
        unzip V2Ray.zip
        cp ${wp}/*.service /etc/systemd/system
        rm -f V2Ray.zip
        if [ -d "/lib64" ];then
            cp ${wp}/koolproxy_x86_64 ${wp}/KoolProxy
            cp ${wp}/pdnsd_x86_64 ${wp}/pdnsd
        else
            cp ${wp}/koolproxy_x86 ${wp}/KoolProxy
            cp ${wp}/pdnsd_x86 ${wp}/pdnsd
        fi
        rm -f ${wp}/*x86*
    } > /dev/null 2>&1 &
clear
echo "检测到系统未安装V2Ray，请根据提示进行安装"
echo
read -p "请输入V2Ray版本[默认${v2ray_version_default}]: " v2ray_version
echo
if [ -z "$v2ray_version" ];then
    echo -e "已选择 \033[33m${v2ray_version_default}\033[0m 版本"
    echo
    v2ray_version=$v2ray_version_default
fi
{
    cd ${wp}
    wget -q -N -P v2ray_download --no-check-certificate https://github.com/v2ray/v2ray-core/releases/download/v${v2ray_version}/v2ray-linux-${linux_digits}.zip
    cd v2ray_download
    unzip -q v2ray-linux-${linux_digits}.zip
    rm -f v2ray-linux-${linux_digits}.zip
    cp */v2ctl ${wp}
    cp */v2ray ${wp}
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
    echo "$E" >> ${wp}/v2ray.ini
    read -p "请设置 ${E} 端口UUID[留空回车随机设置]: " v2ray_uuid
    echo
    if [ -z "$v2ray_uuid" ];then
        v2ray_uuid=$(cat /proc/sys/kernel/random/uuid)
        echo -e "已设置 \033[33m${E}\033[0m 端口UUID为 \033[33m${v2ray_uuid}\033[0m"
        echo
    fi
    echo "$v2ray_uuid" >> ${wp}/v2ray.ini
done
v2ray_config_reload
echo "设置完毕，正在安装"
wait
chmod 777 -R ${wp}
systemctl start v2ray.service
curl -s https://raw.githubusercontent.com/FH0/nubia/master/V2Ray.sh > /bin/v2
chmod +x /bin/v2
vps_information=$(curl -s https://api.myip.com/)
echo $vps_information | grep -Eo '[0-9].*[0-9]' > ${wp}/JZDH.txt
echo $vps_information | awk -F '"cc":"' '{print $2}' | awk -F '"' '{print $1}' >> ${wp}/JZDH.txt
#定时缓存IP信息
echo '*/5 * * * * /bin/v2 ip_update' > ${wp}/crontab
crontab ${wp}/crontab
clear
pannel
}

v2ray_config_reload() {
    v2ray_config_line=$(cat ${wp}/v2ray.ini | wc -l)
    if [ "$v2ray_config_line" = "2" ];then
        echo -e '{\n  "inbound": {\n    "port": '$(sed -n "1p" ${wp}/v2ray.ini)',\n    "protocol": "vmess",\n    "settings": {\n      "clients": [\n        {\n          "id": "'$(sed -n "2p" ${wp}/v2ray.ini)'",\n          "alterId": 100\n        }\n      ]\n    },\n    "streamSettings": {\n      "network": "tcp",\n      "tcpSettings": {\n        "header": {\n          "type": "http",\n          "response": {\n            "version": "1.1",\n            "status": "200",\n            "reason": "OK",\n            "headers": {\n              "Content-Type": [\n                "application/octet-stream",\n                "application/x-msdownload",\n                "text/html",\n                "application/x-shockwave-flash"\n              ],\n              "Connection": [\n                "keep-alive"\n              ]\n            }\n          }\n        }\n      }\n    }\n  },\n  "outbound": {\n    "protocol": "freedom",\n    "settings": {}\n  }\n}' > ${wp}/config.json
    elif (("$v2ray_config_line" > "2"));then
        echo -e '{\n  "inbound": {\n    "port": '$(sed -n "1p" ${wp}/v2ray.ini)',\n    "protocol": "vmess",\n    "settings": {\n      "clients": [\n        {\n          "id": "'$(sed -n "2p" ${wp}/v2ray.ini)'",\n          "alterId": 100\n        }\n      ]\n    },\n    "streamSettings": {\n      "network": "tcp",\n      "tcpSettings": {\n        "header": {\n          "type": "http",\n          "response": {\n            "version": "1.1",\n            "status": "200",\n            "reason": "OK",\n            "headers": {\n              "Content-Type": [\n                "application/octet-stream",\n                "application/x-msdownload",\n                "text/html",\n                "application/x-shockwave-flash"\n              ],\n              "Connection": [\n                "keep-alive"\n              ]\n            }\n          }\n        }\n      }\n    }\n  },\n  "inboundDetour": [' > ${wp}/config.json
        v2ray_ports=$(grep "^[0-9][0-9]*$" ${wp}/v2ray.ini | sed '1d')
        for N in ${v2ray_ports};do
            v2ray_uuid_line=$(($(grep -n "^${N}$" ${wp}/v2ray.ini | awk -F ":" '{print $1}')+1))
            v2ray_uuid=$(sed -n "${v2ray_uuid_line}p" ${wp}/v2ray.ini)
            echo -e '    {\n      "port": '$N',\n      "protocol": "vmess",\n      "settings": {\n        "clients": [\n          {\n            "id": "'$v2ray_uuid'",\n            "alterId": 100\n          }\n        ]\n      },\n      "streamSettings": {\n        "network": "tcp",\n        "tcpSettings": {\n          "header": {\n            "type": "http",\n            "response": {\n              "version": "1.1",\n              "status": "200",\n              "reason": "OK",\n              "headers": {\n                "Content-Type": [\n                  "application/octet-stream",\n                  "application/x-msdownload",\n                  "text/html",\n                  "application/x-shockwave-flash"\n                ],\n                "Connection": [\n                  "keep-alive"\n                ]\n              }\n            }\n          }\n        }\n      }\n    },' >> ${wp}/config.json
        done
        echo -e '  ],\n  "outbound": {\n    "protocol": "freedom",\n    "settings": {}\n  }\n}' >> ${wp}/config.json
        sed -i ':a;N;$!ba;s|,\n  \]|\n  \]|' ${wp}/config.json
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
    rm -rf ${wp}
    rm -f /etc/systemd/system/v2ray.service
    rm -f /bin/v2
    rm -f /etc/systemd/system/DNS.service
    rm -f /etc/systemd/system/koolproxy.service
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
    rm -f ${wp}/v2ray
    rm -f ${wp}/v2ctl
    cp */v2ctl ${wp}
    cp */v2ray ${wp}
    chmod 777 -R ${wp}
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
    useradd pdnsd > /dev/null 2>&1
    if [ -z "$(pgrep pdnsd)" ];then
        systemctl start DNS.service
        systemctl enable DNS.service
        echo '0 1 * * * export PATH="/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin" && ([ -z "$(pgrep pdnsd)" ] || systemctl restart DNS.service)' >> ${wp}/crontab
        crontab ${wp}/crontab
    else
        systemctl stop DNS.service
        systemctl disable DNS.service
        sed -i '/DNS.service/d' ${wp}/crontab
        crontab ${wp}/crontab
    fi > /dev/null 2>&1
    sleep 0.8
    clear
    pannel
}

koolproxy_settings() {
    useradd KoolProxy > /dev/null 2>&1
    if [ -z "$(pgrep KoolProxy)" ];then
        echo '0 1 * * * /bin/v2 koolproxy_update' >> ${wp}/crontab
        crontab ${wp}/crontab
        systemctl start koolproxy.service
        systemctl enable koolproxy.service
    else
        systemctl stop koolproxy.service
        systemctl disable koolproxy.service
        sed -i '/koolproxy_update/d' ${wp}/crontab
        crontab ${wp}/crontab
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

get_v2ray_config() {
    v2ray_ports=$(grep "^[0-9][0-9]*$" ${wp}/v2ray.ini)
    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    for K in ${v2ray_ports};do
        v2ray_uuid=$(sed -n ''$(($(grep -n "^${K}$" ${wp}/v2ray.ini | sed 's|:.*||')+1))''p ${wp}/v2ray.ini)
        v2rayNG=$(echo '{"add":"'$public_ip'","aid":"100","host":"k.youku.com","id":"'$v2ray_uuid'","net":"tcp","path":"","port":"'$K'","ps":"'$City'","tls":"","type":"http","v":"2"}' | base64 | sed ':a;N;$!ba;s|\n||g' | sed 's|^|vmess://|g')
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

port_setting() {
    v2ray_ports=$(grep "^[0-9][0-9]*$" ${wp}/v2ray.ini)
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
            echo "$E" >> ${wp}/v2ray.ini
            read -p "请输入 ${E} 端口UUID[留空回车随机设置]: " v2ray_uuid
            echo
            if [ -z "$v2ray_uuid" ];then
                v2ray_uuid=$(cat /proc/sys/kernel/random/uuid)
                echo -e "已设置 \033[33m${E}\033[0m 端口UUID为\033[33m${v2ray_uuid}\033[0m"
                echo
            fi
            echo "$v2ray_uuid" >> ${wp}/v2ray.ini
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
        sed -i ''$((${del_port_choice}*2-1))'d' ${wp}/v2ray.ini
        sed -i ''$((${del_port_choice}*2-1))'d' ${wp}/v2ray.ini
    elif [ "$port_setting_choice" = "3" ];then
        for S in ${v2ray_ports};do
            echo -e " \033[32m${var}.\033[0m 更改 \033[33m${S}\033[0m 端口UUID"
            var=$((${var}+1))
        done
        echo
        read -p "请选择: " uuid_choice
        echo
        [ -z "$uuid_choice" ] && port_setting
        port_select=$(sed -n ''$((${uuid_choice}*2-1))'p' ${wp}/v2ray.ini)
        read -p "请输入 ${port_select} 端口UUID[留空回车随机设置]: " v2ray_uuid
        echo
        if [ -z "$v2ray_uuid" ];then
            v2ray_uuid=$(cat /proc/sys/kernel/random/uuid)
            echo -e "已设置 \033[33m${port_select}\033[0m 端口UUID为\033[33m${v2ray_uuid}\033[0m"
            echo
        fi
        sed -i ''$((${uuid_choice}*2))'s|.*|'$v2ray_uuid'|' ${wp}/v2ray.ini
    fi
    v2ray_config_reload
    if [ ! -z "$(pgrep v2ray)" ];then
        systemctl restart v2ray.service
        sleep 0.8
    fi
    port_setting
}

connection_info() {
    [ -z "$(pgrep v2ray)" ] && exit 0
    awk_ports=$(grep -Eo "^[0-9][0-9]*$" ${wp}/v2ray.ini | sed 's|^|\:|g;s|$|\$|g' | tr "\n" "|" | sed 's|\|$||')
    connection_ip=$(netstat -anp | grep "^tcp.*ESTABLISHED" | awk '{if($4~/('$awk_ports')/)print $5}' | grep -Eo "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | sort -u)
    for C in ${connection_ip};do
        if [ -z "$(grep $C ${wp}/JZDH.txt)" ];then
            ip_information=$(curl -s 'http://freeapi.ipip.net/'$C'' | sed 's/[[:punct:]]//g')
            [ -z "$ip_information" ] || echo "${C} ${ip_information}" >> ${wp}/JZDH.txt
        fi
    done
    [ "$1" = "update" ] && exit 0
    clear
    [ "$connection_total" = "0" ] && pannel
    port=$(grep -Eo "^[0-9][0-9]*$" ${wp}/v2ray.ini)
    for L in ${port};do
        echo "${L}端口："
        connection_ip=$(netstat -anp | grep "^tcp.*ESTABLISHED" | awk '{if($4~/:'$L'$/)print $5}' | grep -Eo "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | sort -u)
        for X in ${connection_ip};do
            ip_information=$(grep "$X" ${wp}/JZDH.txt | awk '{print $2}')
            printf "  \033[33m%-20s %-40s\033[0m\n" ${X} ${ip_information}
        done
        echo
    done
    pannel
}

koolproxy_info_update(){
    wget -O ${wp}/koolproxy.txt.bak https://kprule.com/koolproxy.txt
    koolproxy_size=$(ls -hl ${wp}/koolproxy.txt.bak | awk '{print $5}' | grep -Eo "[0-9]*")
    if (("$koolproxy_size" > 300));then
        cat ${wp}/koolproxy.txt.bak > ${wp}/koolproxy.txt
    fi
    rm -f ${wp}/koolproxy.txt.bak
    exit 0
}

pannel() {
    v2ray_status=停止
    [ -z "$(pgrep v2ray)" ] && v2ray_status=启动
    bbr_status=关闭
    [ -z "$(lsmod | grep bbr)" ] && bbr_status=启动
    koolproxy_status=停止
    [ -z "$(pgrep KoolProxy)" ] && koolproxy_status=启动
    v2ray_version=$(${wp}/v2ray --version | sed -n "1p" | awk '{print $2}' | sed 's/.\(.*\)/\1/g')
    awk_ports=$(grep -Eo "^[0-9][0-9]*$" ${wp}/v2ray.ini | sed 's|^|\:|g;s|$|\$|g' | tr "\n" "|" | sed 's|\|$||')
    connection_total=$(netstat -anp | grep "^tcp.*ESTABLISHED" | awk '{if($4~/('$awk_ports')/)print $5}' | grep -Eo "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | sort -u | wc -l)
    public_ip=$(cat ${wp}/JZDH.txt | sed -n '1p')
    City=$(cat ${wp}/JZDH.txt | sed -n '2p')
    v2ray_ports=$(grep "^[0-9][0-9]*$" ${wp}/v2ray.ini | tr "\n" " ")

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
    [ -z "$(pgrep pdnsd)" ] || echo -e " \033[32m11.\033[0m 关闭DNS加速解析"
    [ -z "$(pgrep pdnsd)" ] && echo -e " \033[32m11.\033[0m 开启dnsmasq加速DNS解析"
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
    if [ -d "${wp}" ];then
        clear && pannel
    else
        install_v2ray
    fi
elif [ "$1" = "ip_update" ];then
    connection_info update
elif [ "$1" = "koolproxy_update" ];then
    koolproxy_info_update
fi
