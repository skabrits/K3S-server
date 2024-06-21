#!/bin/bash

ip a show eth1 | grep "inet " | awk '{print $2}' | cut -d / -f1
IPADDR=$(ip a show eth1 | grep "inet " | awk '{print $2}' | cut -d / -f1)
while [ -z $IPADDR ] 
do
	IPADDR=$(ip a show eth1 | grep "inet " | awk '{print $2}' | cut -d / -f1)
	ip a show eth1 | grep "inet " | awk '{print $2}' | cut -d / -f1
	sleep 5
done

sudo chown "$(whoami)" /etc/resolv.conf

sudo chmod u+w /etc/resolv.conf

sudo echo "nameserver $(echo $IPADDR | cut -d "." -f1-3).1" >> /etc/resolv.conf

LBIP="$(avahi-resolve -n4 master-01.local | awk '{print $2}')"

curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="777" INSTALL_K3S_VERSION="v1.26.13+k3s2" INSTALL_K3S_EXEC="--node-ip=${IPADDR} --flannel-backend=wireguard-native --node-external-ip=${IPADDR} --flannel-external-ip --flannel-iface=eth1 --disable=traefik --disable=local-storage" K3S_TOKEN=SECRET sh -s - server --server https://${LBIP}:6443 --disable servicelb

#curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="777" INSTALL_K3S_VERSION="v1.26.13+k3s2" INSTALL_K3S_EXEC="--node-ip=${IPADDR} --disable=traefik" K3S_TOKEN=SECRET sh -s - server --server https://${LBIP}:6443 --disable servicelb

# mkdir -p "~/.kube/"

# cp /vagrant/configs/config "~/.kube/config"
