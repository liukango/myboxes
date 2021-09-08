#!/bin/bash

# Tested on CentOS7/8, Debian8/9/10, Ubuntu18/20

# Get main nic name
# NICNAME=$(netstat -nr | grep "^0.0.0.0" | awk '{print $8}')
NICNAME=$(ip r | grep "default" | awk '{print $5}')

# Check if it has IP configed
ip a show dev ${NICNAME} | grep -q "inet " || exit 0

IFS='/'
DHCP_ADDR=($(ip a show dev ${NICNAME} | grep "inet " | awk '{print $2}'))
unset IFS
GATEWAY=$(ip r | grep "default" | awk '{print $3}')

echo "dhcp -> static: ${DHCP_ADDR[0]}/${DHCP_ADDR[1]}"

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

  C_UUID=$(nmcli c show | grep "${NICNAME}" | grep -Eo '[0-9a-z-]{20,}')
  nmcli c mod ${C_UUID} ipv4.address ${DHCP_ADDR[0]}/${DHCP_ADDR[1]}
  nmcli c mod ${C_UUID} ipv4.gateway ${GATEWAY}
  nmcli c mod ${C_UUID} ipv4.method manual
  nmcli c mod ${C_UUID} ipv6.method disabled
  nmcli c mod ${C_UUID} autoconnect yes
  nmcli c up ${C_UUID}

  ip a show ${NICNAME}
fi

# If Ubuntu 18.04 / 20.04
cat /etc/os-release | grep -Eqi "ubuntu (18.04|20.04)"
if [ $? -eq 0 ]  ; then

  IFCFG_FILE="/etc/netplan/01-netcfg.yaml"
  [ -f "${IFCFG_FILE}" ] || exit 0
  sudo cp ${IFCFG_FILE} ${IFCFG_FILE}.back

  # Exit if already static
  grep -A 1 "${NICNAME}" ${IFCFG_FILE} | grep -Eq "dhcp4: (true|yes)" || exit 0

  sudo sed -i '/^\ \ \ \ /d' ${IFCFG_FILE}
  echo "    ${NICNAME}:" | sudo tee -a ${IFCFG_FILE}
  echo "      link-local: []" | sudo tee -a ${IFCFG_FILE}
  echo "      dhcp4: false" | sudo tee -a ${IFCFG_FILE}
  echo "      addresses:" | sudo tee -a ${IFCFG_FILE}
  echo "        - ${DHCP_ADDR[0]}/${DHCP_ADDR[1]}" | sudo tee -a ${IFCFG_FILE}
  echo "      gateway4: ${GATEWAY}" | sudo tee -a ${IFCFG_FILE}
  echo "      nameservers:" | sudo tee -a ${IFCFG_FILE}
  echo "          addresses: [${GATEWAY},114.114.114.114]" | sudo tee -a ${IFCFG_FILE}

  sudo netplan apply
fi

# If debian 8 - 10
cat /etc/os-release | grep -Eqi "debian gnu/linux (8|9|10)"
if [ $? -eq 0 ]  ; then
  IFCFG_FILE="/etc/network/interfaces"
  [ -f "${IFCFG_FILE}" ] || exit 0
  sudo cp ${IFCFG_FILE} ${IFCFG_FILE}.back

  # Exit if already static
  grep -q "iface ${NICNAME} inet static" ${IFCFG_FILE} && exit 0

  sed -i "/iface\ ${NICNAME}\ inet/ciface\ ${NICNAME}\ inet\ static" ${IFCFG_FILE}
  sed -i "/iface\ ${NICNAME}\ inet/a\ \ \ \ dns-nameserver 114.114.114.114" ${IFCFG_FILE}
  sed -i "/iface\ ${NICNAME}\ inet/a\ \ \ \ gateway ${GATEWAY}" ${IFCFG_FILE}
  sed -i "/iface\ ${NICNAME}\ inet/a\ \ \ \ address ${DHCP_ADDR[0]}/${DHCP_ADDR[1]}
" ${IFCFG_FILE}

  ip a show ${NICNAME}
fi
