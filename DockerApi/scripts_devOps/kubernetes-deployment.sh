#!/bin/zsh

kubectl run vinted-pod --image='local/vinted' --image-pull-policy='Never' --expose=true --port=3000
kubectl port-forward vinted-pod 4242:3000