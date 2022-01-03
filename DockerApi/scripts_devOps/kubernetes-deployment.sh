#!/bin/zsh

minikube start
kubectl create deployment vinted --image=emmanuelsarpedon/vinted:latest
kubectl expose deployment vinted --type=NodePort --port=3000
minikube service vinted --url