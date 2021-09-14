#!/bin/bash

# Tested on CentOS7/8, Debian8/9/10, Ubuntu18/20

# Common envirenment virables
NEW_USER=${1}
[ "${1}" ] && NEW_USER_HOME="/home/${NEW_USER}"
PREINSTALLED_PACKAGES=${2}

# OS bootstrap:
# 1. ssh passwordless
# 2. create user ${NEW_USER}
# 3. sudo nopasswd
# 4. set timezone
# 5. disable selinux
# 6. set locale
# 7. install necessary packages

sudo -s << EOF
# 1. ssh passwordless
mkdir -p /root/.ssh && chmod 700 /root/.ssh
cp /tmp/host.ssh/id_rsa /root/.ssh/ && chmod 600 /root/.ssh/id_rsa
cp /tmp/host.ssh/id_rsa.pub /root/.ssh/ && chmod 644 /root/.ssh/id_rsa.pub
cat /tmp/host.ssh/id_rsa.pub >> /root/.ssh/authorized_keys && chmod 600 /root/.ssh/authorized_keys
cp /tmp/host.ssh/config /root/.ssh/ && chmod 644 /root/.ssh/config
rm -rf /tmp/host.ssh
# sed -i '/PermitRootLogin/c PermitRootLogin yes' /etc/ssh/sshd_config
# sed -i '/PasswordAuthentication/c PasswordAuthentication yes' /etc/ssh/sshd_config
systemctl restart sshd

# 2. create user "${NEW_USER}"
if [ "${NEW_USER}" ]; then
    groupadd -g 666 ${NEW_USER} && useradd -g ${NEW_USER} -u 666 -m -s /bin/bash ${NEW_USER}
    cat /etc/group | grep -Eqi "sudo" && usermod -aG sudo ${NEW_USER}
    cat /etc/group | grep -Eqi "wheel" && usermod -aG wheel ${NEW_USER}
    cp -r /root/.ssh ${NEW_USER_HOME}
    chown ${NEW_USER}:${NEW_USER} -R ${NEW_USER_HOME}/.ssh
fi

# 3. sudo nopasswd
cat /etc/os-release | grep -Eqi "centos linux" && \
    usermod -aG wheel vagrant && \
    sed -i "s/^%wheel/# &/; /NOPASSWD/s/^# //" /etc/sudoers \
    || true
cat /etc/os-release | grep -Eqi "(ubuntu|debian)" && \
    sed -i '/^%sudo/s/) ALL/) NOPASSWD:ALL/' /etc/sudoers \
    || true

# 4. set timezone
timedatectl set-timezone Asia/Shanghai

# 5. disable selinux
cat /etc/issue | grep -Eqi "centos" && sed -i '/^SELINUX=/c SELINUX=disabled' /etc/selinux/config && setenforce 0 || true

# 6. set English locale
echo "LANG=en_US.utf-8" >> /etc/environment
echo "LC_ALL=en_US.utf-8" >> /etc/environment

# 7. install necessary packages
if [ "${PREINSTALLED_PACKAGES}" ]; then
    which yum &> /dev/null && \
        echo "Exec: yum makecache ..." && \
        yum makecache &> /dev/null && \
        echo "Installing packages: ${PREINSTALLED_PACKAGES} ..." && \
        yum install -y ${PREINSTALLED_PACKAGES} > /dev/null \
        || true
    which apt &> /dev/null && \
        export DEBIAN_FRONTEND=noninteractive && \
        echo "Exec: apt update ..." && \
        apt-get update &> /dev/null && \
        echo "Installing packages: ${PREINSTALLED_PACKAGES} ..." && \
        apt-get -qq install -y ${PREINSTALLED_PACKAGES} > /dev/null \
        || true
fi

EOF
