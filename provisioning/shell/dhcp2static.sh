#!/bin/bash

# Get main nic name
NICNAME=$(netstat -nr | grep "^0.0.0.0" | awk '{print $8}')

# Check if it has IP configed
ip a show dev ${NICNAME} | grep -q "inet " || exit 0

IFS='/'
DHCP_ADDR=($(ip a show dev ${NICNAME} | grep "inet " | awk '{print $2}'))
unset IFS
GATEWAY=$(ip r | grep "default" | awk '{print $3}')

# If CentOS 7 / CentOS Stream 8
cat /etc/os-release | grep -Eqi "centos (linux 7|stream 8)"
if [ $? -eq 0 ]  ; then

    IFCFG_FILE="/etc/sysconfig/network-scripts/ifcfg-${NICNAME}"
    sudo systemctl disable NetworkManager &> /dev/null
    sudo systemctl stop NetworkManager &> /dev/null

    sudo sed -i '/^BOOTPROTO=dhcp/c BOOTPROTO=static' ${IFCFG_FILE}
    sudo sed -i '/^IPADDR/d' ${IFCFG_FILE}
    sudo sed -i '/^NETMASK/d' ${IFCFG_FILE}
    sudo sed -i '/^PREFIX/d' ${IFCFG_FILE}
    sudo sed -i '/^GATEWAY/d' ${IFCFG_FILE}
    sudo sed -i '/^DNS\d/d' ${IFCFG_FILE}

    echo "IPADDR=${DHCP_ADDR[0]}" | sudo tee -a ${IFCFG_FILE}
    echo "PREFIX=${DHCP_ADDR[1]}" | sudo tee -a ${IFCFG_FILE}
    echo "GATEWAY=${GATEWAY}" | sudo tee -a ${IFCFG_FILE}
    echo "DNS1=${GATEWAY}" | sudo tee -a ${IFCFG_FILE}
    echo "DNS2=114.114.114.114" | sudo tee -a ${IFCFG_FILE}

    sudo systemctl enable network &> /dev/null
    sudo systemctl restart network &> /dev/null
fi

# If CentOS 8
cat /etc/os-release | grep -Eqi "centos linux 8"
if [ $? -eq 0 ]  ; then

  nmcli c mod ${NICNAME} ipv4.address ${DHCP_ADDR[0]}/${DHCP_ADDR[1]}
  nmcli c mod ${NICNAME} ipv4.gateway ${GATEWAY}
  nmcli c mod ${NICNAME} ipv4.method manual
  nmcli c mod ${NICNAME} ipv6.method disabled
  nmcli c mod ${NICNAME} autoconnect yes
  nmcli c up ${NICNAME} > /dev/null
  ip a show ${NICNAME}

fi

# If Ubuntu 18.04 / 20.04
cat /etc/os-release | grep -Eqi "ubuntu (18.04|20.04)"
if [ $? -eq 0 ]  ; then

    IFCFG_FILE="/etc/netplan/01-netcfg.yaml"
    # Exit if already static
    grep -A 1 "${NICNAME}" ${IFCFG_FILE} | grep -Eq "dhcp4: (true|yes)" || exit 0
    sudo sed -i "/${NICNAME}/,+1d" ${IFCFG_FILE}
    echo "    eth0:" | sudo tee -a ${IFCFG_FILE}
    echo "      link-local: []" | sudo tee -a ${IFCFG_FILE}
    echo "      dhcp4: false" | sudo tee -a ${IFCFG_FILE}
    echo "      addresses:" | sudo tee -a ${IFCFG_FILE}
    echo "        - ${DHCP_ADDR[0]}/${DHCP_ADDR[1]}" | sudo tee -a ${IFCFG_FILE}
    echo "      gateway4: ${GATEWAY}" | sudo tee -a ${IFCFG_FILE}
    echo "      nameservers:" | sudo tee -a ${IFCFG_FILE}
    echo "          addresses: [${GATEWAY},114.114.114.114]" | sudo tee -a ${IFCFG_FILE}

    sudo netplan apply
fi

