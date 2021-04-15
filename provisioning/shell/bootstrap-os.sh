#!/bin/bash

# Common envirenment virables
APT_MIRROR_HOST="mirrors.aliyun.com"
PREINSTALLED_PACKAGES=${1:-"vim"}

# OS bootstrap:
# 1. ssh passwordless
# 2. set timezone
# 3. disable selinux
# 4. set locale
# 5. install necessary packages
# 6. change user "vagrant" privilege

sudo -s << EOF

# 1. ssh passwordless
mkdir -p /root/.ssh && chmod 700 /root/.ssh
cp /tmp/host.ssh/id_rsa /root/.ssh/ && chmod 600 /root/.ssh/id_rsa
cp /tmp/host.ssh/id_rsa.pub /root/.ssh/ && chmod 644 /root/.ssh/id_rsa.pub
cat /tmp/host.ssh/id_rsa.pub >> /root/.ssh/authorized_keys && chmod 600 /root/.ssh/authorized_keys
rm -rf /tmp/host.ssh
sed -i '/PermitRootLogin/c PermitRootLogin yes' /etc/ssh/sshd_config
sed -i '/PasswordAuthentication/c PasswordAuthentication yes' /etc/ssh/sshd_config
systemctl restart sshd

# 2. set timezone
timedatectl set-timezone Asia/Shanghai

# 3. disable selinux
cat /etc/issue | grep -Eqi "centos" && sed -i '/^SELINUX=/c SELINUX=disabled' /etc/selinux/config && setenforce 0 || true

# 4. set English locale
echo "LANG=en_US.utf-8" >> /etc/environment
echo "LC_ALL=en_US.utf-8" >> /etc/environment

# 5. install necessary packages
cat /etc/os-release | grep -Eqi "centos linux 7" && \
    yum install -y epel-release > /dev/null && \
    curl -sSL http://mirrors.aliyun.com/repo/epel-7.repo -o /etc/yum.repos.d/epel.repo \
    || true
cat /etc/os-release | grep -Eqi "centos linux 8" && \
    yum install -y https://mirrors.aliyun.com/epel/epel-release-latest-8.noarch.rpm > /dev/null && \
    sed -i 's|^#baseurl=https://download.fedoraproject.org/pub|baseurl=https://mirrors.aliyun.com|' /etc/yum.repos.d/epel* && \
    sed -i 's|^metalink|#metalink|' /etc/yum.repos.d/epel* \
    || true
which yum &> /dev/null && \
    echo "Exec: yum makecache ..." && \
    yum makecache &> /dev/null && \
    echo "Installing packages: ${PREINSTALLED_PACKAGES} ..." && \
    yum install -y ${PREINSTALLED_PACKAGES} > /dev/null \
    || true

cat /etc/os-release | grep -Eqi "ubuntu" && \
    cp /etc/apt/sources.list /etc/apt/sources.list.bk && \
    sed -i 's/archive.ubuntu.com/${APT_MIRROR_HOST}/g;s/security.ubuntu.com/${APT_MIRROR_HOST}/g' /etc/apt/sources.list \
    || true
which apt &> /dev/null && \
    export DEBIAN_FRONTEND=noninteractive && \
    echo "Exec: apt update ..." && \
    apt-get update &> /dev/null && \
    echo "Installing packages: ${PREINSTALLED_PACKAGES} ..." && \
    apt-get -qq install -y ${PREINSTALLED_PACKAGES} > /dev/null \
    || true

# 6. change user "vagrant" privilege
cat /etc/os-release | grep -Eqi "centos linux" && \
    usermod -aG wheel vagrant && \
    sed -i "s/^%wheel/#&/; s/^# %wheel/%wheel/" /etc/sudoers \
    || true
cat /etc/os-release | grep -Eqi "(ubuntu|debina)" && \
    sed -i '/^%sudo/s/) ALL/) NOPASSWD:ALL/' /etc/sudoers \
    || true

EOF
