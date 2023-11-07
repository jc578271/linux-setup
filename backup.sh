#!/bin/bash

read -p "Enter your backup name: " backup_name
sudo mkdir /$backup_name
sudo rsync -aAX /usr /etc /lib /var /$backup_name
sudo tar -czf /$backup_name.tar.gz /$backup_name
sudo rm -rf /$backup_name
