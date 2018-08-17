#!/bin/bash

# 针对不同的node进行不同的provision，通过参数$1传递

PASSWORD=${PASSWORD:-"kk"}
FTP_USER=${FTP_USER:-"ftpuser"}
FTP_ROOT=${FTP_ROOT:-"/ftpfiles"}
FTP_CONF="/etc/vsftpd/vsftpd.conf"

function web1_provision() {
  echo "Provision web1 ..."
  sudo yum install -y tomcat

}
function db_provision() {
  echo "Provision db ..."
  bash /common/scripts/prep-mysql.sh
}
function ftp1_provision() {
  echo "Provision ftp1 ..."
  bash /common/scripts/prep-vsftpd.sh
  bash /common/scripts/prep-nginx.sh
  cp /common/files/nginx/index.html /ftpfiles/
}

if [ $1 = "web1" ]; then
  web1_provision
elif [ $1 = "db1" ]; then
  db_provision
elif [ $1 = "db2" ]; then
  db_provision
elif [ $1 = "ftp1" ]; then
  ftp1_provision
else
  echo "Provision others..."
fi
