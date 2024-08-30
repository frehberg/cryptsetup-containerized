#!/bin/sh -e

## Author: Frank Rehberger
## Date:   2024-08-30
## Usage: ./test-efs-privileged.sh
##
## Test efs on local host with root privileges. The efs will be 
## opened and mounted on host system.
##
## Required Host Tools: 
##   cryptsetup
##   mount
##   df
##   ls
##   sudo 

IMAGE_DIR=tmp/images
IMAGE_FILE=rootfs.img
IMAGE_PATH=${IMAGE_DIR}/${IMAGE_FILE}
PASS_PATH=${IMAGE_DIR}/pass.txt
LABEL=efs
MAPPER_DEV=/dev/mapper/${LABEL}
MOUNT_DIR=/tmp/efs-mount

cleanup()
{
 sudo umount ${MOUNT_DIR} || true
 sudo cryptsetup close ${LABEL} || true
}


trap cleanup EXIT

echo ">>> Opening LUKS fs: ${IMAGE_PATH}"
 
cat ${PASS_PATH} | sudo cryptsetup open ${IMAGE_PATH} ${LABEL} 

echo ">>> Mounting fs: ${MAPPER_DEV}"
mkdir -p ${MOUNT_DIR}
sudo mount ${MAPPER_DEV} ${MOUNT_DIR}
echo ">>> Reading fs ${MOUNT_DIR}"
sudo find ${MOUNT_DIR}
sudo ls -l /tmp/efs-mount/bin/hello
sudo ls ${MOUNT_DIR}
df  ${MOUNT_DIR}

echo "SUCCESS: valid LUKS encrypted file system (efs)"
