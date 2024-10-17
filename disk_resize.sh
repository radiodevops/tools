#!/usr/bin/env bash

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root."
  exit 1
fi

# Update the package repository and install necessary tools
yum update -y
yum install -y cloud-utils-growpart xfsprogs

# Identify the root device and partition (typically /dev/nvme0n1 and /dev/nvme0n1p1)
ROOT_DEVICE="/dev/nvme0n1"
PARTITION="${ROOT_DEVICE}p1"

# Re-scan the disk to detect the new size
echo "Re-scanning the disk..."
sudo partprobe $ROOT_DEVICE

# Print the current partition table
echo "Current partition table:"
sudo fdisk -l $ROOT_DEVICE

# Grow the partition
echo "Growing partition on ${ROOT_DEVICE}..."
sudo growpart $ROOT_DEVICE 1

# Check the filesystem type
FSTYPE=$(lsblk -no FSTYPE $PARTITION)
echo "Filesystem type on ${PARTITION} is ${FSTYPE}"

# Resize the filesystem based on its type
if [ "$FSTYPE" == "xfs" ]; then
  echo "Resizing XFS filesystem on ${PARTITION}..."
  sudo xfs_growfs /
elif [ "$FSTYPE" == "ext4" ]; then
  echo "Resizing ext4 filesystem on ${PARTITION}..."
  sudo resize2fs $PARTITION
else
  echo "Unsupported filesystem type: ${FSTYPE}"
  exit 1
fi

echo "Disk resize complete."

# Verify the new size
df -h /
