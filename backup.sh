#!/bin/bash
set -e

read -p "Enter your backup name: " backup_name
sudo tar  -czf /$backup_name.tar.gz --exclude "/var/swap" /usr /etc /lib /var
