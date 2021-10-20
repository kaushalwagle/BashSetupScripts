#Default values in variables so that we can reuse
#********************************************=

USERNAME="[]"
PASSWORD="[]"
DEFAULT_USER="ubuntu"
DEFAULT_PASSWORD="[]"
HOSTNAME="ubuntu-[]"
MYSQL_PASSWORD=""
INFO_FILE="[]_RPIinfo.txt"
NON_DEFAULT_PHP_CONTENT="base.php"

echo **************************************
echo RUNNING apt update AND apt upgrade
echo **************************************
sudo apt update && sudo apt upgrade -y
echo **************************************


echo **************************************
echo 	INSTALL APACHE SERVER
echo **************************************
sudo apt install apache2 -y
echo **************************************


echo **************************************
echo 	RESTART APACHE SERVER
echo **************************************
sudo a2enmod rewrite
sudo systemctl restart apache2
echo **************************************


echo **********************************************
echo 	INSTALL PHP AND SETUP NON DEFAULT PHP CONTENT
echo **********************************************
sudo apt install php libapache2-mod-php -y
sudo service apache2 restart
sudo chown -R www-data:www-data /var/www
sudo mv /var/www/html/index.html /var/www/html/index.php 
sudo mv /$NON_DEFAULT_PHP_CONTENT  /var/www/html/index.php
echo **********************************************


echo **************************************
echo 	   INSTALL MARIA DB
echo **************************************
sudo apt install mariadb-server -y
echo **************************************


echo **************************************
echo  RESTART APACHE AND MYSQL
echo **************************************
sudo service apache2 restart
sudo service mysql restart
echo **************************************



echo **************************************
echo SETTING A ROOT PASSWORD, REMOVING GUEST/ANONYMOUS USER ACCOUNTS, AND REMOVING THE TEST/DEMO DATABASE.
echo **************************************
#  sudo mysql_secure_installation
sudo mysql -e "SET PASSWORD FOR root@localhost = PASSWORD('$MYSQL_PASSWORD'); FLUSH PRIVILEGES;"
sudo mysql -u root -p$MYSQL_PASSWORD -e "DELETE FROM mysql.user WHERE user='';"
sudo mysql -u root -p$MYSQL_PASSWORD -e "DELETE FROM mysql.user WHERE user='root' AND HOST NOT IN ('localhost', '127.0.0.1','::1');"
sudo mysql -u root -p$MYSQL_PASSWORD -e "DROP DATABASE test; DELETE FROM mysql.db WHERE DB='test' OR Db='test_%';"
echo **************************************


echo **************************************
echo  RESTART APACHE AND MYSQL
echo **************************************
sudo service apache2 restart
sudo service mysql restart
echo **************************************


echo **************************************
echo INSTALL NMAP
echo **************************************
sudo apt install nmap -y
echo **************************************


echo **************************************
echo INSTALL NETTOOLS
echo **************************************
sudo apt install net-tools -y
echo **************************************


echo **************************************
echo INSTALL FIREWALL
echo **************************************
sudo apt install ufw
echo **************************************


echo **************************************
echo OPEN PORTS 22, 80,3306
echo **************************************
sudo ufw status
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 3306
sudo ufw --force enable
echo **************************************


echo **************************************
echo ADD NEW USER
echo **************************************
if [ $(id -u) -eq 0 ]; then
	egrep "^$USERNAME" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
		echo "$USERNAME exists!"
	else
		useradd -m -p "$PASSWORD" "$USERNAME"
		[ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!"
	fi
else
	echo "Only root may add a user to the system."
fi
echo **************************************



echo **************************************
echo SETTING PERMISSION TO NEW USER
echo **************************************
sudo usermod $USERNAME -a -G sudo
echo **************************************


echo **************************************
echo SETTING THE PASSWORD
echo **************************************
echo $USERNAME:$PASSWORD | sudo chpasswd
echo $DEFAULT_USER:$DEFAULT_PASSWORD | sudo chpasswd
echo **************************************



echo **************************************
echo CHANGE HOSTNAME
echo **************************************
sudo hostnamectl set-hostname $HOSTNAME
sudo hostnamectl
echo **************************************


echo ************************************************************
echo SAVE OUTPUT ON A FILE
echo ************************************************************

echo "SETUP INFO:" | sudo tee $INFO_FILE
echo -e $(whoami) >> $INFO_FILE
echo -e $(who) >> $INFO_FILE
echo -e $(date) >> $INFO_FILE
echo -e $(cat /etc/passwd) >> $INFO_FILE
echo -e $(hostnamectl) >> $INFO_FILE
echo -e $(uname -a) >> $INFO_FILE
echo -e $(ifconfig) >> $INFO_FILE
echo -e $(netstat -ant) >> $INFO_FILE
echo -e $(sudo ufw status) >> $INFO_FILE
echo -e $(nmap -sn 192.168.1.1/24) >> $INFO_FILE
echo ************************************************************
