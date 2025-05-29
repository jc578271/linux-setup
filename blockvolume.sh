#!/bin/bash

# List all disks
echo "Available disks:"
lsblk

# Ask for the target disk
echo ""
echo "Enter the disk name (e.g., sdb) that you want to format and mount:"
read target_disk

# Validate disk exists
if [ ! -b "/dev/$target_disk" ]; then
    echo "Error: /dev/$target_disk is not a valid block device"
    exit 1
fi

echo "WARNING: You are about to format /dev/$target_disk. All data will be lost!"
echo "Are you sure you want to continue? (y/N)"
read confirmation
if [[ ! "$confirmation" =~ ^[Yy]$ ]]; then
    echo "Operation cancelled"
    exit 0
fi

# Format the Volume
echo "Formatting /dev/$target_disk..."
sudo mkfs.ext4 /dev/$target_disk

# Create a Mount Point
echo "Creating mount point at /mnt/blockvolume..."
sudo mkdir -p /mnt/blockvolume

# Mount the Volume
echo "Mounting /dev/$target_disk to /mnt/blockvolume..."
sudo mount /dev/$target_disk /mnt/blockvolume

# Add to fstab to persist the mount
echo "Adding entry to /etc/fstab for persistent mount..."
echo "/dev/$target_disk /mnt/blockvolume ext4 defaults 0 0" | sudo tee -a /etc/fstab

# check disk space
echo "Current disk usage:"
df -h --total