#!/bin/bash

sudo swapoff -a

# keeps the swaf off during reboot
(crontab -l 2>/dev/null; echo "@reboot /sbin/swapoff -a") | crontab - || true

sudo growpart /dev/sda 3
sudo lvextend -l +100%FREE /dev/mapper/ubuntu--vg-ubuntu--lv
sudo resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv

sudo apt update && sudo apt install -y avahi-daemon avahi-autoipd libnss-mdns avahi-utils ntp net-tools

sudo ufw disable

echo "sudo route add default gw 192.168.0.1
sudo \`route -n | awk '{ if (\$8 ==\"eth0\" && \$2 != \"0.0.0.0\") print \"route del default gw \" \$2; }'\`" | sudo tee /remove_route.sh

sudo chmod +x /remove_route.sh

echo "[Unit]
Description=Removes wrong route
[Service]
ExecStart=/remove_route.sh
[Install]
WantedBy=multi-user.target" | sudo tee /lib/systemd/system/remove_route.service

sudo systemctl enable remove_route.service --now

sudo route add default gw 192.168.0.1

sudo `route -n | awk '{ if ($8 =="eth0" && $2 != "0.0.0.0") print "route del default gw " $2; }'`
