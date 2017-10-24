#!/bin/bash

# Common envirenment virables
PASSWORD=${1:-"ubuntu"}
APT_MIRROR_HOST="mirrors.aliyun.com"
PYPI_MIRROR_URL="https://pypi.tuna.tsinghua.edu.cn/simple"

# Change password for root and permit root login
sudo -s << EOF

(echo "$PASSWORD";sleep 1;echo "$PASSWORD") | passwd root &> /dev/null

# Add DNS configuration
#echo 'nameserver 8.8.8.8' > /etc/resolvconf/resolv.conf.d/base
#echo 'nameserver 8.8.8.8' > /etc/resolv.conf

# Use Domestic mirror
cp /etc/apt/sources.list /etc/apt/sources.list.bk
sed -i 's/archive.ubuntu.com/${APT_MIRROR_HOST}/g;s/security.ubuntu.com/${APT_MIRROR_HOST}/g' /etc/apt/sources.list
apt-get update
apt-get upgrade -y
apt-get install -y $2

# Use Domestic pypi mirror
echo -e "[global]\nindex-url = ${PYPI_MIRROR_URL}" > /etc/pip.conf

EOF
