#!/bin/bash


# Use this script to setup ssh password-less login,
# MUST copy ssh public key to /tmp/my_id_rsa.pub before use this script.
sudo -s << EOF
mkdir -p /root/.ssh
chmod 700 /root/.ssh
#cat /tmp/my_id_rsa.pub >> /home/$1/.ssh/authorized_keys
cat /tmp/my_id_rsa.pub >> /root/.ssh/authorized_keys
rm -f /tmp/my_id_rsa.pub
chmod 600 /root/.ssh/authorized_keys

sed -i '/PermitRootLogin/c PermitRootLogin yes' /etc/ssh/sshd_config
sed -i '/PasswordAuthentication/c PasswordAuthentication yes' /etc/ssh/sshd_config
[ $1 = "ubuntu" ] && service ssh restart || ([ $1 = "centos" ] && systemctl restart sshd)
EOF
