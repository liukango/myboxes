#!/bin/bash

# Common envirenment virables
PASSWORD=${1:-"root"}
APT_MIRROR_HOST="mirrors.aliyun.com"
PYPI_MIRROR_URL="https://pypi.tuna.tsinghua.edu.cn/simple"

# Change password for root and permit root login
sudo -s << EOF

(echo "$PASSWORD";sleep 1;echo "$PASSWORD") | passwd root &> /dev/null

rm -f /etc/localtime; ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# Change to domestic repo mirror (no need for centos now)
which yum &> /dev/null && \
  echo -e "Installing packages: $2 ... \c" && \
  yum makecache && yum install -y vim $2 > /dev/null && \
  echo "Done"
which apt &> /dev/null && \
  cp /etc/apt/sources.list /etc/apt/sources.list.bk && \
  sed -i 's/archive.ubuntu.com/${APT_MIRROR_HOST}/g;s/security.ubuntu.com/${APT_MIRROR_HOST}/g' /etc/apt/sources.list && \
  export DEBIAN_FRONTEND=noninteractive && \
  echo -e "Installing packages: $2 ... \c" && \
  apt-get update && apt-get -qq install -y $2 > /dev/null && \
  echo "Done"

# Disable selinux
cat /etc/issue | grep -qi "centos" && sed -i '/^SELINUX=/c SELINUX=disabled' /etc/selinux/config && setenforce 0


# Use Domestic pypi mirror
echo -e "[global]\nindex-url = ${PYPI_MIRROR_URL}" > /etc/pip.conf

# Set English Locale
echo "LANG=en_US.utf-8" > /etc/environment
echo "LC_ALL=en_US.utf-8" >> /etc/environment

EOF
