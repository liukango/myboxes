#!/bin/bash


# Load common envirenment virables
. /common/env.sh

# Change password for root and permit root login
sudo -s
echo "[INFO] Set password for root"
(echo "$PASSWORD";sleep 1;echo "$PASSWORD") | passwd root &> /dev/null
echo "[INFO] Permit root login via SSH"
sed -i '/PermitRootLogin/c PermitRootLogin yes' /etc/ssh/sshd_config
sed -i '/PasswordAuthentication/c PasswordAuthentication yes' /etc/ssh/sshd_config
echo "[INFO] Restart SSH service"
service ssh restart

# Add DNS configuration
echo 'nameserver 8.8.8.8' > /etc/resolvconf/resolv.conf.d/base
echo 'nameserver 8.8.8.8' > /etc/resolv.conf

# Use Aliyun mirror
mv /etc/apt/sources.list /etc/apt/sources.list.bk
cp /common/sources.list /etc/apt/ 
apt-get update
