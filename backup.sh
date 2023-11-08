#!/bin/bash

read -p "Enter your backup name: " backup_name
sudo rm /$backup_name.tar.gz

sudo tar --ignore-failed-read --exclude="/var/swap" -czf /$backup_name.tar.gz /usr /etc /lib /var/* | 
while read line; do
    x=$((x+1))
    echo -en "$x extracted\r"
done
