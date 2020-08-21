#!/bin/bash

# Common envirenment virables
APT_MIRROR_HOST="mirrors.aliyun.com"
PREINSTALLED_PACKAGES=${1:-"vim"}

# OS bootstrap:
# 1. ssh passwordless
# 2. set timezone
# 3. set repo mirrors
# 4. disable selinux

sudo -s << EOF

mkdir -p /root/.ssh && chmod 700 /root/.ssh
cp /tmp/host.ssh/id_rsa /root/.ssh/ && chmod 600 /root/.ssh/id_rsa
cp /tmp/host.ssh/id_rsa.pub /root/.ssh/ && chmod 644 /root/.ssh/id_rsa.pub
cat /tmp/host.ssh/id_rsa.pub >> /root/.ssh/authorized_keys && chmod 600 /root/.ssh/authorized_keys
rm -rf /tmp/host.ssh
sed -i '/PermitRootLogin/c PermitRootLogin yes' /etc/ssh/sshd_config
sed -i '/PasswordAuthentication/c PasswordAuthentication yes' /etc/ssh/sshd_config
systemctl restart sshd


timedatectl set-timezone Asia/Shanghai


grep -q "CentOS Linux release 7" /etc/redhat-release && \
    mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup && \
    curl -sSL http://mirrors.aliyun.com/repo/Centos-7.repo -o /etc/yum.repos.d/CentOS-Base.repo && \
    rm -f /etc/yum.repos.d/epel* && \
    curl -sSL http://mirrors.aliyun.com/repo/epel-7.repo -o /etc/yum.repos.d/epel.repo

grep -q "CentOS Linux release 8" /etc/redhat-release && \
    mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup && \
    curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-8.repo && \
    yum install -y https://mirrors.aliyun.com/epel/epel-release-latest-8.noarch.rpm && \
    sed -i 's|^#baseurl=https://download.fedoraproject.org/pub|baseurl=https://mirrors.aliyun.com|' /etc/yum.repos.d/epel* && \
    sed -i 's|^metalink|#metalink|' /etc/yum.repos.d/epel*

which yum &> /dev/null && \
    echo "Exec: yum makecache ..." && \
    yum makecache &> /dev/null && \
    echo "Installing packages: ${PREINSTALLED_PACKAGES} ..." && \
    yum install -y ${PREINSTALLED_PACKAGES} > /dev/null

which apt &> /dev/null && \
    cp /etc/apt/sources.list /etc/apt/sources.list.bk && \
    sed -i 's/archive.ubuntu.com/${APT_MIRROR_HOST}/g;s/security.ubuntu.com/${APT_MIRROR_HOST}/g' /etc/apt/sources.list && \
    export DEBIAN_FRONTEND=noninteractive && \
    echo "Exec: apt update ..." && \
    apt-get update &> /dev/null && \
    echo "Installing packages: ${PREINSTALLED_PACKAGES} ..." && \
    apt-get -qq install -y ${PREINSTALLED_PACKAGES} > /dev/null


cat /etc/issue | grep -qi "centos" && sed -i '/^SELINUX=/c SELINUX=disabled' /etc/selinux/config && setenforce 0

EOF
