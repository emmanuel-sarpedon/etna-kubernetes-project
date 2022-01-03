#!/bin/zsh

kubectl apply -f ./kubernetes/vinted.yml
kubectl expose deployment vinted-deploy --type=NodePort --port=3000
minikube service vinted-deploy --url