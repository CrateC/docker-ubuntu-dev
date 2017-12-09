#!/bin/bash
set -e

service mysql start

sleep 2

echo -e "$MYSQL_ROOT_PASSWORD\nn\nY\nY\nY\nY\n" | mysql_secure_installation

mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "CREATE USER '$MYSQL_USER'@'$MYSQL_HOST' IDENTIFIED BY '$MYSQL_PASSWORD';"
mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_USER'@'$MYSQL_HOST' WITH GRANT OPTION;"
mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "FLUSH PRIVILEGES;"
mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE DEFAULT CHARACTER SET = 'utf8' DEFAULT COLLATE 'utf8_general_ci';"

service mysql stop
