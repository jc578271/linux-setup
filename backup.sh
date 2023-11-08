#!/bin/bash

read -p "Enter your backup name: " backup_name

sudo rm /$backup_name.tar.gz

sudo pv /usr /etc /lib /var/* | sudo tar --ignore-failed-read --exclude="/var/swap" -czf /$backup_name.tar.gz /usr /etc /lib /var/*
