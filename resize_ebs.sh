#!/bin/bash

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root."
  exit 1
fi

# Default volume size in GB if not provided as an argument
DEFAULT_SIZE=50
SIZE=${1:-$DEFAULT_SIZE}

# Function to get AWS metadata token
get_metadata_token() {
  curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"
}

# Function to get instance ID
get_instance_id() {
  local token=$1
  curl -s -H "X-aws-ec2-metadata-token: $token" http://169.254.169.254/latest/meta-data/instance-id
}

# Function to get volume ID
get_volume_id() {
  local instance_id=$1
  aws ec2 describe-volumes \
    --filters Name=attachment.instance-id,Values=$instance_id \
    --query "Volumes[0].VolumeId" \
    --output text
}

# Function to resize EBS volume
resize_ebs_volume() {
  local volume_id=$1
  local size=$2
  aws ec2 modify-volume --volume-id $volume_id --size $size
}

# Function to wait for volume modification to complete
wait_for_volume_modification() {
  local volume_id=$1
  while [ "$(aws ec2 describe-volumes-modifications \
    --volume-id $volume_id \
    --filters Name=modification-state,Values="optimizing","completed" \
    --query "length(VolumesModifications)" \
    --output text)" != "1" ]; do
    sleep 1
  done
}

# Function to determine the root device and partition
determine_root_device() {
  if [ "$(readlink -f /dev/xvda)" = "/dev/xvda" ]; then
    echo "/dev/xvda /dev/xvda1"
  else
    echo "/dev/nvme0n1 /dev/nvme0n1p1"
  fi
}

# Function to re-scan the disk
rescan_disk() {
  local root_device=$1
  sudo partprobe $root_device
}

# Function to grow the partition
grow_partition() {
  local root_device=$1
  sudo growpart $root_device 1
}

# Function to get filesystem type
get_filesystem_type() {
  local partition=$1
  lsblk -no FSTYPE $partition
}

# Function to resize the filesystem
resize_filesystem() {
  local partition=$1
  local fstype=$2
  if [[ "$fstype" == "xfs" ]]; then
    sudo xfs_growfs /
  elif [[ "$fstype" == "ext4" || "$fstype" == "ext3" ]]; then
    sudo resize2fs $partition
  else
    echo "Unsupported filesystem type: $fstype"
    exit 1
  fi
}

# Main script execution

# Get metadata token
TOKEN=$(get_metadata_token)

# Get instance ID
INSTANCEID=$(get_instance_id $TOKEN)

# Get volume ID
VOLUMEID=$(get_volume_id $INSTANCEID)

# Resize the EBS volume
resize_ebs_volume $VOLUMEID $SIZE

# Wait for volume modification to complete
wait_for_volume_modification $VOLUMEID

# Determine root device and partition
read ROOT_DEVICE PARTITION <<< $(determine_root_device)

# Re-scan the disk
echo "Re-scanning the disk..."
rescan_disk $ROOT_DEVICE

# Print the current partition table
echo "Current partition table:"
sudo fdisk -l $ROOT_DEVICE

# Grow the partition
echo "Growing partition on ${ROOT_DEVICE}..."
grow_partition $ROOT_DEVICE

# Get filesystem type
FSTYPE=$(get_filesystem_type $PARTITION)
echo "Filesystem type on ${PARTITION} is ${FSTYPE}"

# Resize the filesystem
echo "Resizing filesystem on ${PARTITION}..."
resize_filesystem $PARTITION $FSTYPE

echo "Disk resize complete."

# Verify the new size
df -h /
