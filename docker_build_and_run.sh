#!/bin/zsh

docker build -t emmanuelsarpedon/vinted:1 ./DockerApi/ && docker run -dp 4242:3000 emmanuelsarpedon/vinted:1