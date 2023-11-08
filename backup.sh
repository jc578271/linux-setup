#!/bin/bash

read -p "Enter your backup name: " backup_name

sudo rm -rf /$backup_name.tar.gz

sudo tar --ignore-failed-read -czvf /$backup_name.tar.gz /usr /etc /lib /var
