#!/bin/bash


# Use this script to setup ssh password-less login,
# MUST copy ssh public key to /tmp/my_id_rsa.pub before use this script.
sudo -s << EOF
mkdir -p /root/.ssh && chmod 700 /root/.ssh
cp /tmp/host.ssh/id_rsa /root/.ssh/ && chmod 600 /root/.ssh/id_rsa
cp /tmp/host.ssh/id_rsa.pub /root/.ssh/ && chmod 644 /root/.ssh/id_rsa.pub
cat /tmp/host.ssh/id_rsa.pub >> /root/.ssh/authorized_keys && chmod 600 /root/.ssh/authorized_keys
rm -rf /tmp/host.ssh

sed -i '/PermitRootLogin/c PermitRootLogin yes' /etc/ssh/sshd_config
#sed -i '/PasswordAuthentication/c PasswordAuthentication yes' /etc/ssh/sshd_config
#systemctl restart sshd
EOF
