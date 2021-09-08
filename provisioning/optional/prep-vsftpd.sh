#!/bin/bash

if [ -f utils.sh ]; then
  UTIL_FILE=utils.sh
elif [ -f /common/scripts/utils.sh ]; then
  UTIL_FILE=/common/scripts/utils.sh
fi
source $UTIL_FILE

FTP_USER=${FTP_USER:-"ftpuser"}
FTP_PSWD=${FTP_PSWD:-"kk"}
FTP_ROOT=${FTP_ROOT:-"/ftpfiles"}

function config_vsftpd() {
  sudo -s << EOF
source $UTIL_FILE
mkdir -p $FTP_ROOT
useradd $FTP_USER -d $FTP_ROOT -s /bin/bash
chown -R $FTP_USER.$FTP_USER $FTP_ROOT
(echo "$FTP_PSWD";sleep 1;echo "$FTP_PSWD") | passwd $FTP_USER &> /dev/null

### Modify vsftpd config file.
set_config "$FTP_CONF" "local_root" "$FTP_ROOT" 2> /dev/null
set_config "$FTP_CONF" "use_localtime" "YES"
set_config "$FTP_CONF" "anonymous_enable" "NO"
set_config "$FTP_CONF" "local_enable" "YES"
set_config "$FTP_CONF" "write_enable" "YES"
set_config "$FTP_CONF" "chroot_local_user" "YES"
set_config "$FTP_CONF" "local_umask" "022"
set_config "$FTP_CONF" "allow_writeable_chroot" "YES"
set_config "$FTP_CONF" "listen" "YES"
set_config "$FTP_CONF" "listen_ipv6" "NO"
set_config "$FTP_CONF" "pasv_enable" "YES"
set_config "$FTP_CONF" "pam_service_name" "vsftpd"
set_config "$FTP_CONF" "pasv_min_port" "61001"
set_config "$FTP_CONF" "pasv_max_port" "62000"

systemctl enable vsftpd
systemctl restart vsftpd

EOF
}


###################################################
# Main
###################################################

iptables_setup

if [ `which apt 2> /dev/null` ]; then
  FTP_CONF="/etc/vsftpd.conf"
  sudo apt install -y vsftpd


elif [ `which yum 2> /dev/null` ]; then
  FTP_CONF="/etc/vsftpd/vsftpd.conf"

  sudo yum install -y vsftpd

  sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config 2> /dev/null
  sudo setenforce 0

fi

config_vsftpd
iptables_allow_port "61001:62000"
iptables_allow_port 20
iptables_allow_port 21
iptables_save_rules
