#!/bin/zsh

docker build -t vinted-api ..
docker run -dp 4242:3000 vinted-api