#!/bin/bash

sudo swapoff -a

# keeps the swaf off during reboot
(crontab -l 2>/dev/null; echo "@reboot /sbin/swapoff -a") | crontab - || true

sudo apt update && sudo apt install -y avahi-daemon avahi-autoipd libnss-mdns avahi-utils

sudo ufw disable
