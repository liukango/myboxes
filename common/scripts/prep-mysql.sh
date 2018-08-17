#!/bin/bash

if [ -f utils.sh ]; then
  UTIL_FILE=utils.sh
elif [ -f /common/scripts/utils.sh ]; then
  UTIL_FILE=/common/scripts/utils.sh
fi
source $UTIL_FILE

DB_USER=${DB_USER:-"root"}
DB_PASSWD=${ROOT_PASSWD:-"kk"}

##################################################################
# Main
##################################################################

# Add mariadb repository
curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash

case $ID in
  ubuntu)
    sudo apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -qq mariadb-server
    sudo systemctl enable mysql

    MY_CNF=/etc/mysql/my.cnf

    sudo sed -i 's/127.0.0.1/0.0.0.0/' /etc/mysql/my.cnf

    unalias cp &> /dev/null
    cp -f /common/files/mariadb-ubuntu/conf.d/*.cnf /etc/mysql/conf.d/

    sudo systemctl restart mysql

    sudo mysql -e "grant all privileges on *.* to '$DB_USER'@'%' identified by '$DB_PASSWD' with grant option; flush privileges;"
    ;;
  centos)
    sudo yum makecache
    sudo yum install -y MariaDB-server
    sudo systemctl enable mariadb

    unalias cp &> /dev/null
    cp -f /common/files/mariadb-centos/my.cnf.d/*.cnf /etc/my.cnf.d/

    sudo systemctl restart mariadb

    sudo mysql -e "grant all privileges on *.* to '$DB_USER'@'%' identified by '$DB_PASSWD' with grant option; flush privileges;"
    ;;
esac


iptables_setup
iptables_allow_port 3306
iptables_save_rules
