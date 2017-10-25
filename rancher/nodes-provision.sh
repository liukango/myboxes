#!/bin/bash

# 针对不同的node进行不同的provision，通过参数$1传递


if [ $1 = "rancherserver" ]; then
  sudo docker run -d --restart=unless-stopped -p 8080:8080 rancher/server:stable
else
  echo "No customized provisioning for $1."
fi
