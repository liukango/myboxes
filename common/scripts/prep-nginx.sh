#!/bin/bash

if [ -f utils.sh ]; then
  UTIL_FILE=utils.sh
elif [ -f /common/scripts/utils.sh ]; then
  UTIL_FILE=/common/scripts/utils.sh
fi
source $UTIL_FILE

if [ `which apt 2> /dev/null` ]; then

  sudo cat > /etc/apt/sources.list.d/nginx.list << EOF
deb http://nginx.org/packages/ubuntu/ xenial nginx
deb-src http://nginx.org/packages/ubuntu/ xenial nginx
EOF
  curl http://nginx.org/keys/nginx_signing.key | sudo apt-key add
  sudo apt-get update
  sudo apt-get install -y nginx

elif [ `which yum 2> /dev/null` ]; then

  sudo cat > /etc/yum.repos.d/nginx.repo << EOF
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/
gpgcheck=0
enabled=1
EOF
  sudo yum makecache
  sudo yum install -y nginx

fi


iptables_setup
iptables_allow_port 80
iptables_save_rules

sudo systemctl enable nginx
sudo cp /common/files/nginx/conf.d/ftp.getset.com.conf /etc/nginx/conf.d/
sudo cp /common/files/nginx/index.html /ftpusers/
sudo systemctl restart nginx
