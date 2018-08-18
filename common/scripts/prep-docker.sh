#!/bin/bash

sudo -s << EOF

# DaoCloud 安装 Docker
# curl -sSL https://get.daocloud.io/docker | sh
uname -a | grep -q ubuntu
curl -sSL https://get.daocloud.io/docker > /tmp/install-docker.sh && sh /tmp/install-docker.sh --mirror Aliyun && rm -f /tmp/install-docker.sh

#if [ $? = 0 ]; then
#  apt install -y docker.io
#else
#  curl -sSL https://get.daocloud.io/docker > /tmp/install-docker.sh && sh /tmp/install-docker.sh --mirror Aliyun && rm -f /tmp/install-docker.sh
#fi

# DaoCloud 加速器
# curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://a4e6a79f.m.daocloud.io
# systemctl restart docker || service docker restart

# Aliyun 加速器
sudo mkdir -p /etc/docker
sudo echo '{"registry-mirrors": ["https://anwk44qv.mirror.aliyuncs.com"]}' > /etc/docker/daemon.json
sudo systemctl daemon-reload
sudo systemctl restart docker

EOF
