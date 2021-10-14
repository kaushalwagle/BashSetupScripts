#!/bin/bash

# Read the user input
#read -p "Enter the user name: " user_name
#read -p "Enter Password" user_password

#Install Updates
#sudo apt update

#Install samba if not installed

if dpkg -s samba |grep -q "^samba[[:space:]]*install$" >/dev/null;
then
   echo "=====Samba is not installed. \r\n Installing...."
   sudo apt-get install samba
else
   echo "=====Already Installed!====="
fi

#Create Directory for Sharing
dir="/home/ubuntu/sambashare"
if [[! -e $dir;]] then
    sudo mkdir $dir
    echo "=====$dir already existis now available"
elif [[! -d $dir;]] then
    echo "=====$dir already exist"
fi

#Edit Config File
config_file_samba="/etc/samba/smb.conf"
config_config_samba="[sambashare]\r\n   comment = Samba on Ubuntu\r\n   path = /home/username/sambashare\r\n   read only = no \r\n   browsable = yes"
#echo $config_file_samba
echo $config_content_samba
if cat $config_file_samba |grep -q "^$config_content_samba" > $config_file_samba; then
   echo $config_content_samba | tee -a $config_file_samba
else
   echo "=====Already Configured"
fi
