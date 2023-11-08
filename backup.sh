#!/bin/bash

read -p "Enter your backup name: " backup_name

sudo rm /$backup_name.tar.gz

sudo tar --ignore-failed-read --exclude={"/var/swap","/var/run","/var/lock"} -czvf /$backup_name.tar.gz /usr /etc /lib /var
