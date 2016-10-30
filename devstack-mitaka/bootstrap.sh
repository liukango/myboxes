#!/bin/bash

# Download devstack sources and deploy
sudo -s << EOF
apt-get install -y git
cd /tmp
git clone -b stable/mitaka https://github.com/openstack-dev/devstack.git
bash devstack/tools/create-stack-user.sh
rm -rf devstack

su - stack << !
cd ~
git clone -b stable/mitaka https://github.com/openstack-dev/devstack.git
cp /vagrant/local.conf devstack/
export GIT_BASE='https://github.com'
devstack/stack.sh
!

EOF
