#!/bin/bash

ssh_key() {
    rm -rf /root/.ssh
    mkdir /root/.ssh
    echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDuwLr5N5CxF51tEOXtJJ3Qr2+uY7lVtZfWNwN59yewWUhc6p77CiWj917TrOgrgGMIIgb7AXU0vrdNr2IFJ0fNdyF9S9dfEU8+KAqr+FUH7ywQ8b2sktbqTyVLEZ/lVcd7/+KPxFIP7L7UILqEIIx0rGPVAax8UEwLtMlJ1fakPL98UMTx94hQ2ZW8LW6MJsKd2RWoMkbsn0Joif3SiUGCeGcY8IDzQC8xUZQPFJxVkHqj5Z4iDqms8TNNaKYp7nirTTGHiFW0x7uSAoBxXqKur+c0JLc3ABi5FIlC3+yVtwVr7l4/eHK7bRb/iERoMNEyVF22U5Sha41NQZquDitF root@localhost' > /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
    echo -e 'X11Forwarding yes\nPrintMotd no\nAcceptEnv LANG LC_*\nSubsystem	sftp	/usr/lib/openssh/sftp-server\nPermitRootLogin yes\nChallengeResponseAuthentication no\nPasswordAuthentication no\nUsePAM no\nRSAAuthentication yes\nPubkeyAuthentication yes\nPort 52714' > /etc/ssh/sshd_config
}

etc_profile() {
    sed -i '/^clear$/d' /etc/profile
    echo "clear" >> /etc/profile
}

etc_hostname() {
    [ -f "/usr/bin/apt-get" ] && linux='debian'
    [ -f "/usr/bin/yum" ] && linux='centos'
    echo "$linux" > /etc/hostname
}

person_bin() {
    echo -e '#!/bin/bash\niptables -t nat -S' > /bin/ins
    echo '#!/bin/bash\niptables -t mangle -S' > /bin/ims
    chmod +x /bin/*
}

rc_local() {
    echo -e '[Unit]\nDescription=/etc/rc.local\nConditionPathExists=/etc/rc.local\n\n[Service]\nType=forking\nExecStart=/etc/rc.local start\nTimeoutSec=0\nStandardOutput=tty\nRemainAfterExit=yes\nSysVStartPriority=99\n\n[Install]\nWantedBy=multi-user.target' > /etc/systemd/system/rc-local.service
    echo -e '#!/bin/sh -e\nexit 0' > /etc/rc.local
    chmod +x /etc/rc.local
    systemctl enable rc-local
    systemctl start rc-local.service
}

dns_set() {
    echo -e 'nameserver 8.8.8.8\nnameserver 8.8.4.4' > /etc/resolv.conf
    echo -e 'nameserver 8.8.8.8\nnameserver 8.8.4.4' > /etc/resolvconf/resolv.conf.d/base
}

main() {
    ssh_key
    etc_profile
    etc_hostname
    dns_set
    person_bin
    rc_local
    reboot
}

main
