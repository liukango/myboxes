#!/bin/bash

sudo -s << EOF

echo "Installing docker ..."

curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun &> /dev/null

[ $? -ne 0 ] && exit 0

echo "Configuration of docker daemon ..."

mkdir -p /etc/docker
cat <<EOC > /etc/docker/daemon.json
{
  "registry-mirrors" : ["https://anwk44qv.mirror.aliyuncs.com"],
  "log-opts": {
    "max-file": "5",
    "max-size": "10m"
  }
}
EOC
systemctl daemon-reload && systemctl restart docker

EOF
