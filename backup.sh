#!/bin/bash

read -p "Enter your backup name: " backup_name
sudo rm /$backup_name.tar.gz

sudo tar --ignore-failed-read -czf /$backup_name.tar.gz /usr /etc /lib /var
