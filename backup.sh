#!/bin/bash

read -p "Enter your backup name: " backup_name
sudo rm /$backup_name.tar.gz
sudo tar  -czf /$backup_name.tar.gz --exclude="/var/swap" /usr /etc /lib /var
