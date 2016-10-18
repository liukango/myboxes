#!/bin/bash

# Download devstack sources and deploy
sudo -s << EOF
apt-get install -y git
cd /tmp
git clone https://github.com/openstack-dev/devstack.git
git checkout -b stable/mitaka origin/stable/mitaka
bash devstack/tools/create-stack-user.sh
rm -rf devstack

su - stack << !
cd ~
git clone https://github.com/openstack-dev/devstack.git
git checkout -b stable/mitaka origin/stable/mitaka
cp /vagrant/local.conf devstack/
export GIT_BASE='https://github.com'
devstack/stack.sh
!

EOF
