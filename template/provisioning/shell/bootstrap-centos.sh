#!/bin/bash

# Common envirenment virables
PASSWORD=${1:-"centos"}
PYPI_MIRROR_URL="https://pypi.tuna.tsinghua.edu.cn/simple"

# Change password for root and permit root login
sudo -s << EOF
(echo "$PASSWORD";sleep 1;echo "$PASSWORD") | passwd root &> /dev/null

rm -f /etc/localtime; ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

echo 'export http_proxy=http://10.0.2.2:1080/pac' >> /etc/bashrc
echo 'export https_proxy=http://10.0.2.2:1080/pac' >> /etc/bashrc

#eval $(cat /etc/os-release | grep VERSION_ID)
#echo "VERSION_ID: $VERSION_ID"
#mkdir -p /etc/yum.repos.d/backup
#mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/backup
#curl -so /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-$(cat /etc/os-release | grep VERSION_ID | awk -F '\"' '{print $2}').repo
yum makecache
yum install -y wget git vim $2

# Use Domestic pypi mirror
echo -e "[global]\nindex-url = ${PYPI_MIRROR_URL}" > /etc/pip.conf
EOF
