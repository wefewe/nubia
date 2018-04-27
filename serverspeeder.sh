#!/bin/bash

function check {
	if [ -f /etc/redhat-release ];then
		OS='CentOS' && yum install net-tools -y && centos_kernel_boot
	elif [ ! -z "`cat /etc/issue | grep bian`" ];then
		OS='Debian' && apt-get install net-tools -y && boot && kernel && network && grub
	elif [ ! -z "`cat /etc/issue | grep Ubuntu`" ];then
		OS='Ubuntu' && apt-get install module-init-tools -y && apt-get install net-tools -y && boot && kernel && network && grub
	else
		echo "Not support OS, Please reinstall OS and retry!"
		exit 1
	fi
}

function boot {
	if [[ ${OS} == Debian ]];then
		if [ -z "`cat /etc/issue|grep " 7"`" ];then
			cat <<EOF >/etc/rc.local
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.
wget -N --no-check-certificate https://github.com/91yun/serverspeeder/raw/master/serverspeeder-v.sh && bash serverspeeder-v.sh Debian 8 3.16.0-4-amd64 x64 3.10.61.0 serverspeeder_31604 && rm -f serverspeeder-v.sh && sed -i "/91yun/d" /etc/rc.local
exit 0
EOF
chmod +x /etc/rc.local
systemctl start rc-local
else
	cat <<EOF >/etc/rc.local
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.
wget -N --no-check-certificate https://github.com/91yun/serverspeeder/raw/master/serverspeeder-v.sh && bash serverspeeder-v.sh Debian 7 3.2.0-4-amd64 x64 3.10.61.0 serverspeeder_2626 && rm -f serverspeeder-v.sh && sed -i "/91yun/d" /etc/rc.local
exit 0
EOF
chmod +x /etc/rc.local
fi
elif [[ ${OS} == Ubuntu ]];then
	echo '#!/bin/bash
	wget -N --no-check-certificate https://github.com/91yun/serverspeeder/raw/master/serverspeeder-v.sh && bash serverspeeder-v.sh Ubuntu 14.04 _3.16.0-28-generic x64 3.10.61.0 serverspeeder_2719 && rm -f serverspeeder-v.sh
	sed -i "/sser/d" /etc/rc.local && rm -f /root/sser.sh
	' > /root/sser.sh
	chmod +x /root/sser.sh
	sed -i "/exit/d" /etc/rc.local && echo -e "/root/sser.sh\nexit 0" >> /etc/rc.local
fi
}

function kernel {
	if [[ ${OS} == Debian ]];then
		if [ -z "`cat /etc/issue|grep " 7"`" ];then
			wget --no-check-certificate http://ftp.debian.org/debian/pool/main/l/linux/linux-image-3.16.0-4-amd64_3.16.51-3_amd64.deb
			dpkg -i linux-image-3.16.0-4-amd64_3.16.51-3_amd64.deb
			rm -f linux-image-3.16.0-4-amd64_3.16.51-3_amd64.deb
		else
			wget --no-check-certificate http://ftp.debian.org/debian/pool/main/l/linux/linux-image-3.2.0-4-amd64_3.2.78-1_amd64.deb
			dpkg -i linux-image-3.2.0-4-amd64_3.2.78-1_amd64.deb
			rm -f linux-image-3.2.0-4-amd64_3.2.78-1_amd64.deb
		fi
	elif [[ ${OS} == Ubuntu ]];then
		wget --no-check-certificate http://security.ubuntu.com/ubuntu/pool/main/l/linux-lts-utopic/linux-image-3.16.0-28-generic_3.16.0-28.38~14.04.1_amd64.deb && dpkg -i linux-image-3.16.0-28-generic_3.16.0-28.38~14.04.1_amd64.deb && rm -f linux-image-3.16.0-28-generic_3.16.0-28.38~14.04.1_amd64.deb
	fi
}

function network {
	cp /etc/network/interfaces /etc/network/interfaces.bak
	echo 'auto lo     
	iface lo inet loopback

	auto eth0                          
	iface eth0 inet dhcp' > /etc/network/interfaces
}

function grub {
	if [[ ${OS} == Debian ]];then
		if [ -z "`cat /etc/issue|grep " 7"`" ];then
			sed -i "s:^GRUB_DEFAULT=.*:GRUB_DEFAULT=\"Advanced options for Debian GNU/Linux>Debian GNU/Linux, with Linux 3.16.0-4-amd64\":g" /etc/default/grub
			sed -i "s:^GRUB_CMDLINE_LINUX=.*:GRUB_CMDLINE_LINUX=\"net.ifnames=0 biosdevname=0\":g" /etc/default/grub
			update-grub
		else
			sed -i "s:^GRUB_DEFAULT=.*:GRUB_DEFAULT=\"Debian GNU/Linux, with Linux 3.2.0-4-amd64\":g" /etc/default/grub
			sed -i "s:^GRUB_CMDLINE_LINUX=.*:GRUB_CMDLINE_LINUX=\"net.ifnames=0 biosdevname=0\":g" /etc/default/grub
			update-grub
		fi
	elif [[ ${OS} == Ubuntu ]];then
		sed -i "s:^GRUB_DEFAULT=.*:GRUB_DEFAULT=\"Advanced options for Ubuntu>Ubuntu, with Linux 3.16.0-28-generic\":g" /etc/default/grub
		sed -i "s:^GRUB_CMDLINE_LINUX=.*:GRUB_CMDLINE_LINUX=\"net.ifnames=0 biosdevname=0\":g" /etc/default/grub
		update-grub
	fi
}

function centos_kernel_boot {
	if [ ! -z "`cat /etc/redhat-release|grep 7.`" ];then
		rpm -ivh https://buildlogs.cdn.centos.org/c7.1511.00/kernel/20151119220809/3.10.0-327.el7.x86_64/kernel-3.10.0-327.el7.x86_64.rpm --force
		cat > /etc/rc.d/init.d/sser << eof
wget -N --no-check-certificate https://github.com/91yun/serverspeeder/raw/master/serverspeeder-v.sh && bash serverspeeder-v.sh CentOS 7.2 3.10.0-327.el7.x86_64 x64 3.11.20.5 serverspeeder_72327
rm -f serverspeeder-v.sh
sed -i "/sser/d" /etc/rc.d/rc.local
rm -f "/etc/rc.d/init.d/sser"
eof
chmod +x  /etc/rc.d/init.d/sser
echo "/etc/rc.d/init.d/sser" >> /etc/rc.d/rc.local
chmod +x /etc/rc.d/rc.local
elif [ ! -z "`cat /etc/redhat-release|grep 6.`" ];then
	rpm -ivh http://vault.centos.org/6.0/centosplus/x86_64/RPMS/kernel-2.6.32-71.7.1.el6.centos.plus.x86_64.rpm --force
	cat > /etc/rc.d/init.d/sser << eof
wget -N --no-check-certificate https://github.com/91yun/serverspeeder/raw/master/serverspeeder-v.sh && bash serverspeeder-v.sh CentOS 6.0 2.6.32-71.el6.x86_64 x64 3.10.24.1 serverspeeder_1757 && rm -f serverspeeder-v.sh
sed -i "/sser/d" /etc/rc.d/rc.local
rm -f "/etc/rc.d/init.d/sser"
eof
chmod +x  /etc/rc.d/init.d/sser
echo "/etc/rc.d/init.d/sser" >> /etc/rc.d/rc.local
chmod +x /etc/rc.d/rc.local
fi
}

check
