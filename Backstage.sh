#!/bin/bash
yum install unzip wget net-tools tar curl -y || apt-get install unzip wget net-tools tar curl -y

#下载解压离线包
area=$(curl -s http://freeapi.ipip.net/`curl -s ifconfig.me`|awk 'gsub(/\["/,""){print $0}'|awk 'gsub(/"\,.*/,""){print $0}')
if [ "$area" = "中国" ];then
    wget https://gitee.com/just1601/tiny-sh/blob/master/ssr_jzdh.zip
else
    wget https://raw.githubusercontent.com/FH0/nubia/master/ssr_jzdh.zip
fi
unzip -o ssr_jzdh.zip -d /usr/local/bin
chmod -R 0777 /usr/local/bin/SSR-Bash-Python

#生成管理后台
echo -e '#!/bin/bash\n\nclear\n\nwp=/usr/local/bin/SSR-Bash-Python\n\necho \necho " 1.安装SSR"\necho " 2.安装V2Ray"\necho " 3.安装BBR"\necho " 4.安装锐速"\necho \necho " 5.进入SSR管理面板(ssr)"\necho " 6.进入V2Ray管理面板(v2)"\necho \necho " 7.卸载SSR"\necho " 8.卸载V2Ray"\necho \nread -p "请选择: " choice\n\nif [ "$choice" = 1 ];then\n    bash ${wp}/install.sh\nelif [ "$choice" = 2 ];then\n    bash ${wp}/jzdh/v2ray.sh\nelif [ "$choice" = 3 ];then\n    bash ${wp}/jzdh/bbr.sh\nelif [ "$choice" = 4 ];then\n    bash ${wp}/jzdh/serverspeeder.sh\nelif [ "$choice" = 5 ];then\n    ssr\nelif [ "$choice" = 6 ];then\n    v2\nelif [ "$choice" = 7 ];then\n    bash ${wp}/uninstall.sh\nelif [ "$choice" = 8 ];then\n    echo\n    read -p "回车继续"\n    systemctl stop v2ray\n    systemctl disable v2ray\n    rm -rf /usr/local/bin/v2ray > /dev/null 2>&1\n    rm -f /etc/systemd/system/v2ray.service > /dev/null 2>&1\n    rm -f /bin/v2\n    clear\n    echo " v2ray已停止并且已卸载"\n    echo\nelse\n    clear\n    echo "请重新输入"\n    echo\nfi\n' > /bin/jzdh
chmod +x /bin/jzdh

#完成后
(sleep 5 && rm -r $0) > /dev/null 2>&1 &
clear
echo " 安装完成，输入jzdh进入后台"
echo
