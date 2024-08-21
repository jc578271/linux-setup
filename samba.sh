#!/bin/bash
set -e
# Start SSH
echo "Start SSH..."
sudo systemctl enable ssh --now

echo "Install Samba"
sudo apt-get update
sudo apt-get install samba ntp
sudo smbpasswd -a $USER

# edit smb.conf
if grep -Fxq "[share]" /etc/samba/smb.conf
then
echo "[share] is already added"
else
echo "adding [share]..."
sudo tee -a /etc/samba/smb.conf > /dev/null <<EOT
[share]
path = /
browseable = yes
writeable = yes
read only = no
create mask = 0755
directory mask = 0755
guest ok = no
security = user
write list = $USER
force user = root
EOT
echo "[InnovateAsterisk] is added"
fi
sudo service smbd restart
