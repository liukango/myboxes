#!/bin/bash

# Download devstack sources and deploy
sudo -s << EOF
apt-get install -y git
cd /tmp
git clone -b stable/$1 https://github.com/openstack-dev/devstack.git
export HOST_IP=$2
devstack/tools/create-stack-user.sh
rm -rf devstack

su - stack << !
cd ~
git clone -b stable/$1 https://github.com/openstack-dev/devstack.git
cp /vagrant/local.conf devstack/
export HOST_IP=$2
devstack/stack.sh
!

EOF
