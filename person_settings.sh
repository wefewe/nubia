#!/bin/bash

ssh_key() {
    rm -rf /root/.ssh
    mkdir /root/.ssh
    echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDuwLr5N5CxF51tEOXtJJ3Qr2+uY7lVtZfWNwN59yewWUhc6p77CiWj917TrOgrgGMIIgb7AXU0vrdNr2IFJ0fNdyF9S9dfEU8+KAqr+FUH7ywQ8b2sktbqTyVLEZ/lVcd7/+KPxFIP7L7UILqEIIx0rGPVAax8UEwLtMlJ1fakPL98UMTx94hQ2ZW8LW6MJsKd2RWoMkbsn0Joif3SiUGCeGcY8IDzQC8xUZQPFJxVkHqj5Z4iDqms8TNNaKYp7nirTTGHiFW0x7uSAoBxXqKur+c0JLc3ABi5FIlC3+yVtwVr7l4/eHK7bRb/iERoMNEyVF22U5Sha41NQZquDitF root@localhost' >> /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
    sed -i '/ChallengeResponseAuthentication /d' /etc/ssh/sshd_config
    sed -i '/PasswordAuthentication /d' /etc/ssh/sshd_config
    sed -i '/UsePAM /d' /etc/ssh/sshd_config
    sed -i '/RSAAuthentication /d' /etc/ssh/sshd_config
    sed -i '/PubkeyAuthentication /d' /etc/ssh/sshd_config
    sed -i '/Port /d' /etc/ssh/sshd_config
    echo 'ChallengeResponseAuthentication no
    PasswordAuthentication no
    UsePAM no
    RSAAuthentication yes
    PubkeyAuthentication yes
    Port 52714' > /etc/ssh/sshd_config
}

etc_profile() {
    echo "clear" >> /etc/profile
}

etc_hostname() {
    [ -f "/usr/bin/apt-get" ] && linux='debian'
    [ -f "/usr/bin/yum" ] && linux='centos'
    echo "$linux" > /etc/hostname
}

person_bin() {
    echo '#!/bin/bash

    iptables -t nat -S' > /bin/ins
    chmod +x /bin/ins
    echo '#!/bin/bash

    iptables -t mangle -S' > /bin/ims
    chmod +x /bin/ims
}

rc_local() {
    echo '[Unit]
    Description=/etc/rc.local Compatibility
    ConditionFileIsExecutable=/etc/rc.local
    After=network.target

    [Service]
    Type=forking
    ExecStart=/etc/rc.local start
    TimeoutSec=0
    RemainAfterExit=yes
    GuessMainPID=no' > /lib/systemd/system/rc-local.service
    echo '#!/bin/bash
    iptables -t mangle -p tcp -A PREROUTING --dport 52714 -j ACCEPT
    iptables -t mangle -p tcp -A PREROUTING --dport 22 -j DROP
    iptables -t mangle -p tcp -A PREROUTING --dport 10000:65535 -j DROP
    iptables -t mangle -p udp -A PREROUTING --dport 10000:65535 -j DROP
    iptables -t mangle -p icmp -A PREROUTING --dport 10000:65535 -j DROP
    exit 0' > /etc/rc.local
    chmod 777 /etc/rc.local
    systemctl daemon-reload
    systemctl enable rc-local
}

main() {
    ssh_key
    etc_profile
    etc_hostname
    person_bin
    rc_local
    reboot
}

main
