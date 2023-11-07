#!/bin/bash

read -p "Enter your backup name: " backup_name
sudo rm /$backup_name.tar.gz
sudo tar  -czf /$backup_name.tar.gz /usr /etc /lib /var/backups /var/cache /var/lib /var/local /var/log
