#!/bin/bash

sudo swapoff -a

# keeps the swaf off during reboot
(crontab -l 2>/dev/null; echo "@reboot /sbin/swapoff -a") | crontab - || true

sudo growpart /dev/sda 3
sudo lvextend -l +100%FREE /dev/mapper/ubuntu--vg-ubuntu--lv
sudo resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv

sudo apt update && sudo apt install -y avahi-daemon avahi-autoipd libnss-mdns avahi-utils ntp net-tools

sudo ufw disable

sudo route add default gw 192.168.0.1

sudo `route -n | awk '{ if ($8 =="eth0" && $2 != "0.0.0.0") print "route del default gw " $2; }'`
