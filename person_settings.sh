#!/bin/bash

ssh_key() {
    rm -rf /root/.ssh
    mkdir /root/.ssh
    echo -e 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDuwLr5N5CxF51tEOXtJJ3Qr2+uY7lVtZfWNwN59yewWUhc6p77CiWj917TrOgrgGMIIgb7AXU0vrdNr2IFJ0fNdyF9S9dfEU8+KAqr+FUH7ywQ8b2sktbqTyVLEZ/lVcd7/+KPxFIP7L7UILqEIIx0rGPVAax8UEwLtMlJ1fakPL98UMTx94hQ2ZW8LW6MJsKd2RWoMkbsn0Joif3SiUGCeGcY8IDzQC8xUZQPFJxVkHqj5Z4iDqms8TNNaKYp7nirTTGHiFW0x7uSAoBxXqKur+c0JLc3ABi5FIlC3+yVtwVr7l4/eHK7bRb/iERoMNEyVF22U5Sha41NQZquDitF root@localhost' >> /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
}

etc_profile() {
    echo -e "clear" >> /etc/profile
}

etc_hostname() {
    [ -f "/usr/bin/apt-get" ] && linux='debian'
    [ -f "/usr/bin/yum" ] && linux='centos'
    echo "$linux" > /etc/hostname
}

person_bin() {
    cat > /bin/ins << jzdh
#!/bin/bash

iptables -t nat -S
jzdh
chmod +x /bin/ins
cat > /bin/ims << jzdh
#!/bin/bash

iptables -t mangle -S
jzdh
chmod +x /bin/ims
}

main() {
    ssh_key
    etc_profile
    etc_hostname
    person_bin
}

main
