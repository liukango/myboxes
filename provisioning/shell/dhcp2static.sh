#!/bin/bash

# Tested on CentOS7/8, Debian8/9/10, Ubuntu18/20

# Apply only for provider 'parallels' and 'virtualbox' with the following situations:
#   'parallels' usually setup one nic
#   'virtualbox' usually setup two nic, one for NAT(10.0.2.15), and the other for private_network
NICNAME=$(ip r | grep -Ev "(10.0.2|169.254)" | tail -n 1 | awk '{print $3}')

# Check if it has IP configed
ip a show dev ${NICNAME} | grep -q "inet " || exit 0

IFS='/'
DHCP_ADDR=($(ip a show dev ${NICNAME} | grep "inet " | awk '{print $2}'))
unset IFS
GATEWAY=$(ip r | grep -Ev "(10.0.2|169.24)" | grep "default" | awk '{print $3}')

echo "dhcp -> static: ${DHCP_ADDR[0]}/${DHCP_ADDR[1]}"

# If CentOS 7 / CentOS Stream 8
# cat /etc/os-release | grep -Eqi "centos (linux 7|stream 8)"
# if [ $? -eq 0 ]  ; then
# 
#   IFCFG_FILE="/etc/sysconfig/network-scripts/ifcfg-${NICNAME}"
#   sudo systemctl disable NetworkManager &> /dev/null
#   sudo systemctl stop NetworkManager &> /dev/null
# 
#   sudo sed -i '/^BOOTPROTO=dhcp/c BOOTPROTO=static' ${IFCFG_FILE}
#   sudo sed -i '/^IPADDR/d' ${IFCFG_FILE}
#   sudo sed -i '/^NETMASK/d' ${IFCFG_FILE}
#   sudo sed -i '/^PREFIX/d' ${IFCFG_FILE}
#   sudo sed -i '/^GATEWAY/d' ${IFCFG_FILE}
#   sudo sed -i '/^DNS\d/d' ${IFCFG_FILE}
# 
#   echo "IPADDR=${DHCP_ADDR[0]}" | sudo tee -a ${IFCFG_FILE}
#   echo "PREFIX=${DHCP_ADDR[1]}" | sudo tee -a ${IFCFG_FILE}
#   [ "${GATEWAY}" ] && echo "GATEWAY=${GATEWAY}" | sudo tee -a ${IFCFG_FILE}
#   echo "DNS1=${GATEWAY}" | sudo tee -a ${IFCFG_FILE}
#   echo "DNS2=8.8.8.8" | sudo tee -a ${IFCFG_FILE}
#   echo "DNS3=114.114.114.114" | sudo tee -a ${IFCFG_FILE}
# 
#   sudo systemctl enable network &> /dev/null
#   sudo systemctl restart network &> /dev/null
# fi

# If CentOS 7 / 8 / Stream 8
cat /etc/os-release | grep -Eqi "centos linux"
if [ $? -eq 0 ]  ; then

  C_UUID=$(nmcli c show | grep "${NICNAME}" | grep -Eo '[0-9a-z-]{20,}')
  nmcli c mod ${C_UUID} ipv4.address ${DHCP_ADDR[0]}/${DHCP_ADDR[1]}
  [ "${GATEWAY}" ] && nmcli c mod ${C_UUID} ipv4.gateway ${GATEWAY}
  [ "${GATEWAY}" ] && nmcli c mod ${C_UUID} ipv4.dns "${GATEWAY},8.8.8.8,114.114.114.114" || nmcli c mod ${C_UUID} ipv4.dns "8.8.8.8,114.114.114.114"
  nmcli c mod ${C_UUID} ipv4.method manual
  nmcli c mod ${C_UUID} ipv6.method disabled &> /dev/null || nmcli c mod ${C_UUID} ipv6.method ignore #centos7 does not know "disabled"
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
  [ "${GATEWAY}" ] && echo "      gateway4: ${GATEWAY}" | sudo tee -a ${IFCFG_FILE}
  echo "      nameservers:" | sudo tee -a ${IFCFG_FILE}
  echo "          addresses: [${GATEWAY},8.8.8.8,114.114.114.114]" | sudo tee -a ${IFCFG_FILE}

  sudo netplan apply

  # Ubuntu use systemd-resolved to manage nameservers
  RESOLVED_FILE="/etc/systemd/resolved.conf"
  [ -f "${RESOLVED_FILE}" ] || exit 0
  sudo cp ${RESOLVED_FILE} ${RESOLVED_FILE}.back
  echo -e "\n#Appended by provisioning script: dhcp2static.sh" >> ${RESOLVED_FILE}
  [ "${GATEWAY}" ] && echo "DNS=${GATEWAY} 8.8.8.8" >> ${RESOLVED_FILE}
  echo "FallbackDNS=114.114.114.114" >> ${RESOLVED_FILE}
  echo "Domains=shared" >> ${RESOLVED_FILE}
  systemctl restart systemd-resolved

fi

# If debian 8 - 11
cat /etc/os-release | grep -Eqi "debian gnu/linux (8|9|10|11)"
if [ $? -eq 0 ]  ; then
  IFCFG_FILE="/etc/network/interfaces"
  [ -f "${IFCFG_FILE}" ] || exit 0
  sudo cp ${IFCFG_FILE} ${IFCFG_FILE}.back

  # Exit if already static
  grep -q "iface ${NICNAME} inet static" ${IFCFG_FILE} && exit 0

  sed -i "/iface\ ${NICNAME}\ inet/ciface\ ${NICNAME}\ inet\ static" ${IFCFG_FILE}
  sed -i "/iface\ ${NICNAME}\ inet/a\ \ \ \ dns-nameserver ${GATEWAY},8.8.8.8,114.114.114.114" ${IFCFG_FILE}
  [ "${GATEWAY}" ] && sed -i "/iface\ ${NICNAME}\ inet/a\ \ \ \ gateway ${GATEWAY}" ${IFCFG_FILE}
  sed -i "/iface\ ${NICNAME}\ inet/a\ \ \ \ address ${DHCP_ADDR[0]}/${DHCP_ADDR[1]}
" ${IFCFG_FILE}

  ip a show ${NICNAME}

  systemctl disable --now systemd-resolved &> /dev/null
  echo "# Overwrite by vagrant provisioning dhcp2static.sh" > /etc/resolv.conf
  [ "${GATEWAY}" ] && echo "nameserver=${GATEWAY}" >> /etc/resolv.conf
  echo "nameserver=8.8.8.8" >> /etc/resolv.conf
  echo "nameserver=114.114.114.114" >> /etc/resolv.conf
fi

