#!/bin/bash

read -p "Enter your backup name: " backup_name

sudo rm /$backup_name.tar.gz

sudo tar --ignore-failed-read --exclude="/var/swap" --checkpoint=100 --totals --checkpoint-action="exec='p=\$(echo "\$TAR_CHECKPOINT/$blocks" | bc -l);printf \"%.4f%%\r\" \$p'" -czf /$backup_name.tar.gz /usr /etc /lib /var/*
