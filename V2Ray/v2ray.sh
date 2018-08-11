#!/bin/bash
export PATH="/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin"

#安装v2ray
rm -rf /bin/v2ray > /dev/null 2>&1
rm -f /etc/systemd/system/v2ray.service > /dev/null 2>&1
rm -f /etc/systemd/system/koolproxy.service > /dev/null 2>&1
rm -f /bin/v2 > /dev/null 2>&1
mkdir -p /bin/v2ray/data/rules
cp ${0%/*}/* /bin/v2ray
cp ${0%/*}/kp.dat /bin/v2ray/data/rules
cp ${0%/*}/koolproxy.txt /bin/v2ray/data/rules
cp ${0%/*}/*.service /etc/systemd/system
rm -f /etc/systemd/system/DNS.service
uuid=$(grep "id" /bin/v2ray/config.json | awk -F '"id": "' '{print $2}' | awk -F '",' '{print $1}' | sort -u)
UUID=$(cat /proc/sys/kernel/random/uuid)
sed -i 's/'$uuid'/'$UUID'/g' /bin/v2ray/config.json
chmod 777 -R /bin/v2ray
userdel koolproxy_i386 > /dev/null 2>&1
useradd koolproxy_i386
sed -i '/v2 /d' /var/spool/cron/root
echo '* * * * * /bin/v2 get' > /var/spool/cron/root
crontab /var/spool/cron/root

#启动v2ray
systemctl stop v2ray.service
systemctl enable v2ray.service
systemctl start v2ray.service

#控制面板
cp ${0%/*}/v2 /bin
chmod +x /bin/v2
cp ${0%/*}/koolproxy /bin
chmod +x /bin/koolproxy
