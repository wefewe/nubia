#!/bin/bash

github=raw.githubusercontent.com/chiakge/Linux-NetSpeed/master

if [ -f /etc/redhat-release ];then
cat > /etc/rc.d/init.d/s_bbr << eof
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sysctl -p
sed -i "/s_bbr/d" /etc/rc.d/rc.local
rm -f "/etc/rc.d/init.d/s_bbr"
eof
chmod +x  /etc/rc.d/init.d/s_bbr
echo "/etc/rc.d/init.d/s_bbr" >> /etc/rc.d/rc.local
chmod +x /etc/rc.d/rc.local


else
cat >/etc/init.d/s_bbr <<EOF
#!/bin/sh
### BEGIN INIT INFO
# Provides:          s_bbr
# Required-Start: $local_fs $remote_fs
# Required-Stop: $local_fs $remote_fs
# Should-Start: $network
# Should-Stop: $network
# Default-Start:        2 3 4 5
# Default-Stop:         0 1 6
# Short-Description: s_bbr
# Description: s_bbr
### END INIT INFO
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sysctl -p
cd /etc/init.d
update-rc.d -f s_bbr remove
rm -f /etc/init.d/s_bbr
EOF
chmod 777 /etc/init.d/s_bbr
cd /etc/init.d
update-rc.d s_bbr defaults 95
fi

BBR_grub(){
if [[ "${release}" == "centos" ]]; then
if [[ ${version} = "6" ]]; then
if [ ! -f "/boot/grub/grub.conf" ]; then
echo -e "${Error} /boot/grub/grub.conf 找不到，请检查."
exit 1
fi
sed -i 's/^default=.*/default=0/g' /boot/grub/grub.conf
elif [[ ${version} = "7" ]]; then
if [ ! -f "/boot/grub2/grub.cfg" ]; then
echo -e "${Error} /boot/grub2/grub.cfg 找不到，请检查."
exit 1
fi
grub2-set-default 0
fi
elif [[ "${release}" == "debian" || "${release}" == "ubuntu" ]]; then
/usr/sbin/update-grub
fi
}

installbbr(){
kernel_version="4.11.8"
if [[ "${release}" == "centos" ]]; then
rpm --import http://${github}/bbr/${release}/RPM-GPG-KEY-elrepo.org
yum install -y http://${github}/bbr/${release}/${version}/${bit}/kernel-ml-${kernel_version}.rpm
yum remove -y kernel-headers
yum install -y http://${github}/bbr/${release}/${version}/${bit}/kernel-ml-headers-${kernel_version}.rpm
yum install -y http://${github}/bbr/${release}/${version}/${bit}/kernel-ml-devel-${kernel_version}.rpm
elif [[ "${release}" == "debian" || "${release}" == "ubuntu" ]]; then
mkdir bbr && cd bbr
wget -N --no-check-certificate http://${github}/bbr/debian-ubuntu/linux-headers-${kernel_version}-all.deb
wget -N --no-check-certificate http://${github}/bbr/debian-ubuntu/${bit}/linux-headers-${kernel_version}.deb
wget -N --no-check-certificate http://${github}/bbr/debian-ubuntu/${bit}/linux-image-${kernel_version}.deb

dpkg -i linux-headers-${kernel_version}-all.deb
dpkg -i linux-headers-${kernel_version}.deb
dpkg -i linux-image-${kernel_version}.deb
cd .. && rm -rf bbr
fi
}

check_sys(){
if [[ -f /etc/redhat-release ]]; then
release="centos"
elif cat /etc/issue | grep -q -E -i "debian"; then
release="debian"
elif cat /etc/issue | grep -q -E -i "ubuntu"; then
release="ubuntu"
elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
release="centos"
elif cat /proc/version | grep -q -E -i "debian"; then
release="debian"
elif cat /proc/version | grep -q -E -i "ubuntu"; then
release="ubuntu"
elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
release="centos"
fi
}
check_version(){
if [[ -s /etc/redhat-release ]]; then
version=`grep -oE  "[0-9.]+" /etc/redhat-release | cut -d . -f 1`
else
version=`grep -oE  "[0-9.]+" /etc/issue | cut -d . -f 1`
fi
bit=`uname -m`
if [[ ${bit} = "x86_64" ]]; then
bit="x64"
else
bit="x32"
fi
}

check_sys
check_version
installbbr
BBR_grub
