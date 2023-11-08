#!/bin/bash

read -p "Enter your backup name: " backup_name
sudo rm /$backup_name.tar.gz
sudo tar --no-wildcards --ignore-failed-read --ignore-command-error /$backup_name.tar.gz -czf /usr /etc /lib /var
