#!/bin/bash

set -e

LOG_TEMP="log_temp_$(date +%s)"
BACKUP_TEMP="backup_temp_$(date +%s)"

sudo ls /
read -p "Input your backup path (backup): " backup_path

read -p "Do you want to remove external packages (y/n): " isRemovePackages

if [ "$isRemovePackages" = "y" ];
then
#Unzip backup folder to backup folder
echo "Unzip backup..."
mkdir $BACKUP_TEMP
sudo tar --ignore-command-error -xf /$backup_path.tar.gz -C $BACKUP_TEMP

#Find and cat to txt
mkdir $LOG_TEMP
sudo find $BACKUP_TEMP -type f | awk '{print substr($0, index($0, "/")+1)}' > $LOG_TEMP/backup_list.txt
sudo find /usr /etc /lib /var /home -type f | awk '{print substr($0, index($0, "/")+1)}' > $LOG_TEMP/current_list.txt

# Remove the external packages
awk 'FNR==NR {a[$0];next}!($0 in a) {print $0}' $LOG_TEMP/backup_list.txt $LOG_TEMP/current_list.txt | awk '{print "sudo rm -rf " $0}' > $LOG_TEMP/result.sh

echo "Remove external packages..."
bash $LOG_TEMP/result.sh

sudo rm -rf $LOG_TEMP
sudo rm -rf $BACKUP_TEMP
fi

# Reset system
echo "Reset system..."
cd / && sudo tar --ignore-command-error --recursive-unlink -xf $backup_path.tar.gz
