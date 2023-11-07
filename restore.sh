#!/bin/bash

BACKUPTMP_PATH="backup_temp_$(date +%s)"

sudo ls /
read -p "Input your backup path (backup): " backup_path

#Unzip backup folder to backup folder
sudo tar -xf /$backup_path.tar.gz $backup_path/

mkdir $BACKUPTMP_PATH

#Find and cat to txt
sudo find $backup_path -type f | awk '{print substr($NF, index($NF, "/")+1)}' >>
sudo find /usr /etc /lib /var -type f | awk '{print substr($NF, index($NF, "/")>

# Remove the external packages
awk 'FNR==NR {a[$0];next}!($0 in a) {print $0}' $BACKUPTMP_PATH/backup_list.txt>

echo "Remove external packages..."
bash $BACKUPTMP_PATH/result.sh

rm -rf $BACKUPTMP_PATH
sudo rm -rf $backup_path

# Reset system
echo "Reset system..."
cd / && sudo tar --recursive-unlink -xf $backup_path.tar.gz

