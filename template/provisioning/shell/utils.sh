#!/bin/bash

. /etc/os-release

##################################################################
# Set 'key=value' for simple configuration files.
##################################################################
function get_distro() {
  echo $ID
}

##################################################################
# Set 'key=value' for simple configuration files.
#   $1: configuration file
#   $2: key
#   $3: value
##################################################################
function set_config() {
  if [[ ! -f $1 ]]; then
    echo "Configuration file $1 does not exsit!"
    exit 1
  elif [[ `grep $2"=" $1` ]]; then
    sudo sed -i 's/^.*'$2'=.*/'$2'='$3'/' $1
  else
    sudo echo -e "$2=$3" >> $1
  fi
}

##################################################################
# Set 'key=value' for configuration files with [section].
#   $1: configuration file
#   $2: section
#   $3: key
#   $4: value
##################################################################
function set_config_under_section() {
  file=$1; section=$2; item=$3; val=$4 
  if [ ! -f $1 ]; then
    echo "No such file: $1"
    exit 1
  elif [[ `grep ${item}\s*= $1` ]]; then
    sudo awk -F '=' '/\['${section}'\]/{a=1} (a==1 && "'${item}'"==$1){gsub($2,"'${val}'");a=0} {print $0}' ${file} 1<>${file}
  else
    sudo sed -i '/\['${section}'\]/a\'${item}'='${val}'' ${file}
  fi

}


##################################################################
# Enable iptables as the only firewall.
##################################################################
function iptables_setup() {
  case $ID in
    ubuntu)
      sudo apt install -y iptables
      sudo ufw disable
    ;;
    centos)
      sudo yum install -y iptables iptables-services
      sudo systemctl disable firewalld
      sudo systemctl stop firewalld
      sudo systemctl enable iptables
      sudo systemctl start iptables
    ;;
  esac
}

##################################################################
# Allow/block iptables ports of TCP protocal for both input & output.
#   $1: port(s)
##################################################################
function iptables_allow_port() {
  sudo iptables -C INPUT -p TCP --dport $1 -j ACCEPT &> /dev/null
  if [[ $? != 0 ]]; then
    sudo iptables -I INPUT -p TCP --dport $1 -j ACCEPT
  fi
  sudo iptables -C OUTPUT -p TCP --sport $1 -j ACCEPT &> /dev/null
  if [[ $? != 0 ]]; then
    sudo iptables -I OUTPUT -p TCP --sport $1 -j ACCEPT
  fi
}
function iptables_block_port() {
  sudo iptables -C INPUT -p TCP --dport $1 -j ACCEPT &> /dev/null
  if [[ $? = 0 ]]; then
    sudo iptables -I INPUT -p TCP --dport $1 -j ACCEPT
  fi
  sudo iptables -C OUTPUT -p TCP --sport $1 -j ACCEPT &> /dev/null
  if [[ $? = 0 ]]; then
    sudo iptables -I OUTPUT -p TCP --sport $1 -j ACCEPT
  fi
}


##################################################################
# Save iptables rules (ubuntu/centos).
##################################################################
function iptables_save_rules() {
  case $ID in
    ubuntu)
      sudo iptables-save > /etc/iptables.up.rules
      if [ `grep "pre-up iptables-restore" /etc/network/interfaces` ]; then
        sudo sed -i '/pre-up iptabbles-restore/d' /etc/network/interfaces
      else
        sudo echo "pre-up iptables-restore < /etc/iptables.up.rules" >> /etc/network/interfaces
      fi
      ;;
    centos)
      sudo service iptables save
      sudo systemctl restart iptables
      ;;
  esac
}

