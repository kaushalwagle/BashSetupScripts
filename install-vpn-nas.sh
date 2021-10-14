#!/bin/bash

# Read the user input
#read -p "Enter the user name: " user_name
#read -p "Enter Password" user_password

#Install Updates
sudo apt update

#Install samba if not installed

if dpkg -s samba |grep -q "^samba[[:space:]]*install$" >/dev/null;
then
   echo -e "=====Samba is not installed. \r\n Installing...."
   sudo apt-get install samba
else
   echo -e "=====Already Installed!====="
fi

#Create Directory for Sharing
dir="/home/ubuntu/sambashare"
if [[ ! -e $dir ]]; then
    sudo mkdir $dir
elif [[ ! -d $dir ]]; then
    echo "=====$dir already exists but is not a director" 1>&2
fi