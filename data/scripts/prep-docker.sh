#!/bin/bash

sudo -s << EOF

# DaoCloud 安装 Docker
curl -sSL https://get.daocloud.io/docker | sh

# DaoCloud 加速器
curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://a4e6a79f.m.daocloud.io
systemctl restart docker || service docker restart

EOF
