#!/bin/bash

# Common envirenment virables
PASSWORD=${1:-"root"}
APT_MIRROR_HOST="mirrors.aliyun.com"
PYPI_MIRROR_URL="https://pypi.tuna.tsinghua.edu.cn/simple"

# Change password for root and permit root login
sudo -s << EOF

(echo "$PASSWORD";sleep 1;echo "$PASSWORD") | passwd root &> /dev/null

echo 'export http_proxy=$3' >> /etc/bash.bashrc
echo 'export https_proxy=$3' >> /etc/bash.bashrc

rm -f /etc/localtime; ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

which yum &> /dev/null && \
  yum makecache && yum install -y wget git vim $2
which apt &> /dev/null && \
  cp /etc/apt/sources.list /etc/apt/sources.list.bk && \
  sed -i 's/archive.ubuntu.com/${APT_MIRROR_HOST}/g;s/security.ubuntu.com/${APT_MIRROR_HOST}/g' /etc/apt/sources.list && \
  apt-get update && apt-get install -y $2 

# Use Domestic pypi mirror
echo -e "[global]\nindex-url = ${PYPI_MIRROR_URL}" > /etc/pip.conf

EOF
