#!/bin/bash

kubectl create namespace argocd
kubectl apply -n argocd -f "/vagrant/manifests/argocd.yaml"
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "ClusterIP"}}'
kubectl apply -f "/vagrant/manifests/argo-cm.yaml"
kubectl -n argocd rollout restart deploy argocd-repo-server

kubectl apply -f "/vagrant/manifests/ingress.yaml"
kubectl apply -f "/vagrant/manifests/argocd"
