#! /bin/bash

apt update
apt install -y apache2 mysql-server mysql-client php
wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-4%2Bubuntu20.04_all.deb
dpkg -i zabbix-release_6.0-4+ubuntu20.04_all.deb
apt update

apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent


mysql -u root -e "create database zabbix character set utf8mb4 collate utf8mb4_bin;"
mysql -u root -e "create user zabbix@localhost identified by 'password';"
mysql -u root -e "grant all privileges on zabbix.* to zabbix@localhost;"
mysql -u root -e "set global log_bin_trust_function_creators = 1;"
# mysql -u root -e "FLUSH PRIVILEGES;"
mysql -u root -e "quit;" 

zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p zabbix

mysql -u root -e "set global log_bin_trust_function_creators = 0;"
# mysql -u root -e "FLUSH PRIVILEGES;"
mysql -u root -e "quit;"

cd /etc/zabbix/
sed -i '129s/#//g' zabbix_server.conf
sed -i 's/DBPassword=/DBPassword=password/g' zabbix_server.conf

systemctl restart zabbix-server zabbix-agent apache2
systemctl enable zabbix-server zabbix-agent apache2 
