#!/bin/bash

# Common envirenment virables
PASSWORD=${1:-"centos"}
PYPI_MIRROR_URL="https://pypi.tuna.tsinghua.edu.cn/simple"

# Change password for root and permit root login
sudo -s << EOF
(echo "$PASSWORD";sleep 1;echo "$PASSWORD") | passwd root &> /dev/null

#eval $(cat /etc/os-release | grep VERSION_ID)
#echo "VERSION_ID: $VERSION_ID"
mkdir -p /etc/yum.repos.d/backup
mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/backup
curl -so /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-$(cat /etc/os-release | grep VERSION_ID | awk -F '\"' '{print $2}').repo
yum makecache
yum install -y wget git vim $2

# Use Domestic pypi mirror
echo -e "[global]\nindex-url = ${PYPI_MIRROR_URL}" > /etc/pip.conf
EOF
