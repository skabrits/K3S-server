#!/bin/bash

# Getting Required IPs
ip a show eth1 | grep "inet " | awk '{print $2}' | cut -d / -f1
IPADDR=$(ip a show eth1 | grep "inet " | awk '{print $2}' | cut -d / -f1)
while [ -z $IPADDR ] 
do
	IPADDR=$(ip a show eth1 | grep "inet " | awk '{print $2}' | cut -d / -f1)
	ip a show eth1 | grep "inet " | awk '{print $2}' | cut -d / -f1
	sleep 5
done
LB_IP=$(grep 'ALoadBalancer' /etc/hosts | awk -F " " '{print $1}')

sudo chown "$(whoami)" /etc/resolv.conf

sudo chmod u+w /etc/resolv.conf

sudo echo "nameserver $(echo $IPADDR | cut -d "." -f1-3).1" >> /etc/resolv.conf

curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="777" INSTALL_K3S_VERSION="v1.26.13+k3s2" K3S_TOKEN=SECRET INSTALL_K3S_EXEC="--node-ip=${IPADDR} --flannel-backend=wireguard-native --node-external-ip=${IPADDR} --flannel-external-ip --disable=traefik --disable=local-storage" sh -s - server --cluster-init --tls-san "$(cat /vagrant/LB_IP)" --disable servicelb

# curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="777" INSTALL_K3S_VERSION="v1.26.13+k3s2" K3S_TOKEN=SECRET INSTALL_K3S_EXEC="--node-ip=${IPADDR} --disable=traefik" sh -s - server --cluster-init --tls-san "$(cat /vagrant/LB_IP)" --disable servicelb

# Adding configs for dev kubectl (and token jic)
mkdir -p /vagrant/configs

cp /var/lib/rancher/k3s/server/node-token /vagrant/configs/
chmod a+r /etc/rancher/k3s/k3s.yaml

cp /etc/rancher/k3s/k3s.yaml /vagrant/configs/config
chmod a+r /vagrant/configs/config
sudo sed -i "s/127.0.0.1/$(cat /vagrant/LB_IP)/g" /vagrant/configs/config

sudo rm -rf /vagrant/LB_IP

# argocd prereq

mkdir -p "~/.kube/"

cp /vagrant/configs/config "~/.kube/config"

# sudo kubectl apply -f "https://raw.githubusercontent.com/projectcalico/calico/v3.27.2/manifests/calico.yaml"

# Deploying metal-lb
sudo kubectl apply -f "/vagrant/manifests/metallb.yaml"

until sudo kubectl create -f /vagrant/manifests/configmap.yaml 2>/dev/null
do
    echo "applying ip pool"
    sleep 10;
done

