#!/bin/bash
export PATH="/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin"

ssh_key() {
    [ -d "/root/.ssh" ] || mkdir /root/.ssh
    echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDuwLr5N5CxF51tEOXtJJ3Qr2+uY7lVtZfWNwN59yewWUhc6p77CiWj917TrOgrgGMIIgb7AXU0vrdNr2IFJ0fNdyF9S9dfEU8+KAqr+FUH7ywQ8b2sktbqTyVLEZ/lVcd7/+KPxFIP7L7UILqEIIx0rGPVAax8UEwLtMlJ1fakPL98UMTx94hQ2ZW8LW6MJsKd2RWoMkbsn0Joif3SiUGCeGcY8IDzQC8xUZQPFJxVkHqj5Z4iDqms8TNNaKYp7nirTTGHiFW0x7uSAoBxXqKur+c0JLc3ABi5FIlC3+yVtwVr7l4/eHK7bRb/iERoMNEyVF22U5Sha41NQZquDitF root@localhost' >> /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
    sed -i '/ChallengeResponseAuthentication/d' /etc/ssh/sshd_config
    sed -i '/PasswordAuthentication/d' /etc/ssh/sshd_config
    sed -i '/Port /d' /etc/ssh/sshd_config
    echo 'ChallengeResponseAuthentication no' >> /etc/ssh/sshd_config
    echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config
    echo 'Port 52714' >> /etc/ssh/sshd_config
    systemctl restart sshd
}

etc_profile() {
    sed -i '/^clear$/d' /etc/profile
    echo "clear" >> /etc/profile
}

person_bin() {
    echo -e '#!/bin/bash\niptables -t nat -S' > /bin/ins
    echo -e '#!/bin/bash\niptables -t mangle -S' > /bin/ims
    echo -e '#!/bin/bash\niptables -t raw -S' > /bin/irs
    echo -e '#!/bin/bash\niptables -S' > /bin/ifs
    chmod +x /bin/*
}

rc_local() {
    echo -e '[Unit]\nDescription=/etc/rc.local\nConditionPathExists=/etc/rc.local\n\n[Service]\nType=forking\nExecStart=/etc/rc.local start\nTimeoutSec=0\nStandardOutput=tty\nRemainAfterExit=yes\nSysVStartPriority=99\n\n[Install]\nWantedBy=multi-user.target' > /etc/systemd/system/rc-local.service
    echo -e '#!/bin/sh -e\nexit 0' > /etc/rc.local
    chmod +x /etc/rc.local
    systemctl enable rc-local
    systemctl start rc-local.service
}

install_nginx() {
    apt-get install nginx aria2 -y
    rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
    yum install nginx -y
    [ -d "/nginx_share" ] || mkdir /nginx_share
    chmod 777 /nginx_share
    useradd nginx
    echo -e 'user  nginx;\nworker_processes  1;\npid        /var/run/nginx.pid;\n \nevents {\n    worker_connections  1024;\n}\n \nhttp {\n    server {\n        listen  8888;\n        server_name  localhost;\n        charset utf-8;\n        root /nginx_share;\n        location / {\n            autoindex on;\n            autoindex_exact_size on;\n            autoindex_localtime on;\n        }\n    }\n}' > /etc/nginx/nginx.conf
    systemctl stop nginx.service
    systemctl disable nginx.service
    curl -s https://raw.githubusercontent.com/FH0/nubia/master/ngx > /bin/ngx
    chmod +x /bin/ngx
}

set_bash() {
    sed -i '/^PS1/d' /root/.bashrc
    echo "PS1='\[\e[47;30m\]\u@debian\[\e[m\]:\w\\$ '" >> /root/.bashrc
    chmod 644 /root/.bashrc
    [ -f "/usr/bin/yum" ] && sed -i 's|debian|centos|' /root/.bashrc
}

language_cn() {
    sed -i 's/.*zh_CN.UTF-8/zh_CN.UTF-8/g' /etc/locale.gen
    locale-gen
    export LANG=zh_CN.UTF-8
    sed -i '/^LANG/d' /root/.bashrc
    echo 'LANG=zh_CN.UTF-8' >> /root/.bashrc
}

main() {
    apt-get install curl wget jq locales net-tools make unzip tar zip vim dnsutils -y
    yum install curl wget net-tools jq locales make unzip tar zip vim bind-utils -y
    ssh_key
    language_cn
    etc_profile
    person_bin
    rc_local
    install_nginx
    set_bash
}

main
clear
