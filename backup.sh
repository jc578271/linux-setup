#!/bin/bash

read -p "Enter your backup name: " backup_name

sudo rm /$backup_name.tar.gz

sudo pv /$backup_name.tar.gz | tar --ignore-failed-read --exclude="/var/swap" -czf /usr /etc /lib /var/*
