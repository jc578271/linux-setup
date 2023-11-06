#!/bin/bash

# Start SSH
echo "Start SSH..."
sudo systemctl enable ssh --now

echo "Install Samba"
sudo apt-get update
sudo apt-get install samba ntp git
read -p "Add Samba username:" USERNAME
sudo smbpasswd -a $USERNAME

# edit smb.conf
sudo nano /etc/samba/smb.conf
sudo service smbd restart
