#!/bin/bash

#mysql5.6自动安装及密码设置
mysql_root_pwd=$MYSQLPWD
mysql_new_pw=$MYSQL_ROOT_PASSWORD

chmod -R 777 /var/lib/mysql/

if [ $mysql_new_pw ];then
	mysqlpwd=$MYSQL_ROOT_PASSWORD
else
	mysqlpwd=$MYSQLPWD
fi

sed -i '/\[mysqld\]/askip-grant-tables' /etc/my.cnf
su - mysql <<EOF
nohup mysqld &
EOF

sleep 7

echo "waiting for mysql start..."

echo "your mysql password is '$mysqlpwd'"
mysql -uroot << EOF
use mysql;
update user set password = Password('$mysqlpwd') where User = 'root';
commit;
flush privileges;
GRANT ALL PRIVILEGES ON *.* TO root@"%" IDENTIFIED BY "$mysqlpwd";
flush privileges;
delete from mysql.user where host!="%";
EOF

sed -i '/skip-grant-tables/d' /etc/my.cnf
killpid=`ps -ef |grep mysqld | grep -v grep | cut -c 9-15 | xargs kill -9`

