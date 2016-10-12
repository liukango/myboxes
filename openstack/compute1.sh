#!/usr/bin/env bash

# Setup network for eth2
sudo sed -i '/iface eth2 inet dhcp/s/dhcp/manual/g' /etc/network/interfaces
sudo sed -i '/\$IFACE/d' /etc/network/interfaces
sudo sed -i '$i up ip link set dev $IFACE up\ndown ip link set dev $IFACE down' /etc/network/interfaces
ifdown eth2
ifup eth2
