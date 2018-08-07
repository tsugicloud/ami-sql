#! /bin/bash

source /home/ubuntu/tsugi_env.sh

if [ -z "$MYSQL_ROOT_PASSWORD" ] ; then
  echo "Must set MYSQL_ROOT_PASSWORD to run this script"
  exit
fi
mysql_root=$MYSQL_ROOT_PASSWORD

export DEBIAN_FRONTEND=noninteractive
export LC_ALL=C.UTF-8
echo ======= Pre-MySQL: Update
apt-get update
echo ======= Install MySQL
echo "mysql-server-5.6 mysql-server/root_password password $mysql_root" | sudo debconf-set-selections
echo "mysql-server-5.6 mysql-server/root_password_again password $mysql_root" | sudo debconf-set-selections
apt-get -y install mysql-server-5.6
echo ======= Cleanup Starting
df
rm -rf /var/lib/apt/lists/*
df
echo ======= Cleanup Done 

# Mysql
# sed -i -e 's/127.0.0.1/0.0.0.0/g' /etc/mysql/mysql.conf.d/mysqld.cnf

# Make it so mysql can touch the local file system
rm /var/log/mysql/error.log
chmod -R ug+rw /var/lib/mysql
chown -R mysql:mysql /var/lib/mysql

# https://stackoverflow.com/questions/9083408/fatal-error-cant-open-and-lock-privilege-tables-table-mysql-host-doesnt-ex
# This happens if /var/lib/mysql is a fresh mount
if [ ! -f /var/lib/mysql/mysql ]; then
    echo Re-initializing the mysql database
    mysql_install_db --user=mysql --ldata=/var/lib/mysql

    echo Starting mysql
    service mysql start
    # Note this is different than in the AMI since it is 100% fresh
    if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
        echo "Setting mysql root password to default pw"
        /usr/bin/mysqladmin -u root password root
    else
        echo "Setting mysql root password to $MYSQL_ROOT_PASSWORD"
        /usr/bin/mysqladmin -u root password "$MYSQL_ROOT_PASSWORD"
    fi
else
    echo Starting mysql
    service mysql start
fi
