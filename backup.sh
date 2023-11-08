#!/bin/bash

read -p "Enter your backup name: " backup_name
sudo rm /$backup_name.tar.gz
sudo tar  -czf --ignore-failed-read /$backup_name.tar.gz /usr /etc /lib /var
