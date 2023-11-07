#!/bin/bash

BACKUPTMP_PATH="backup_temp_$(date +%s)"

sudo ls /
read -p "Input your backup path (backup): " backup_path

#Unzip backup folder
cd / && sudo tar -xf $backup_path.tar.gz

mkdir $BACKUPTMP_PATH

#Find and cat to txt
sudo find $backup_path -type f | awk '{print substr($NF, index($NF, "/")+1)}' > $BACKUPTMP_PATH/backup_list.txt
sudo find /usr /etc /lib /var -type f | awk '{print substr($NF, index($NF, "/")+1)}' > $BACKUPTMP_PATH/current_list.txt

awk 'FNR==NR {a[$0];next}!($0 in a) {print $0}' $BACKUPTMP_PATH/backup_list.txt $BACKUPTMP_PATH/current_list.txt | awk '{print "sudo rm -rf " $0}' > $BACKUPTMP_PATH/result.sh

bash $BACKUPTMP_PATH/result.sh
echo "Run bash..."
cat  $BACKUPTMP_PATH/result.sh

rm -rf $BACKUPTMP_PATH
sudo rm -rf $backup_path
