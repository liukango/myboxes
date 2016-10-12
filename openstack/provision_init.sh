#!/usr/bin/env bash

echo "[INFO] Set password for root"
(echo "$1";sleep 1;echo "$1") | sudo passwd root &> /dev/null
echo "[INFO] Permit root login via SSH"
sudo sed -i '/PermitRootLogin/s/without-password/yes/g' /etc/ssh/sshd_config
echo "[INFO] Restart SSH service"
sudo service ssh restart

# Update hosts
sudo sed -i '/# controller/,$d' /etc/hosts
sudo cat /vagrant/hosts >> /etc/hosts
