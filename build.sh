#!/bin/sh

## Author: Frank Rehberger
## Date:   2024-08-30
## Usage: ./build.sh
##
## Build encryted file system (efs) without extended privileges 
## in containers.
##
## Required Host Tools: 
##   docker
##   mkdir

## Size in MB
IMAGE_SIZE=4096
IMAGE_DIR=tmp/images
IMAGE_FILE=rootfs.img
IMAGE_PATH=${IMAGE_DIR}/${IMAGE_FILE}
LUKS_PASS=mysecret

# build the container
docker build -t container -f Dockerfile .

# create the plain ext4 image (aka file system)
# executing scripts/create-plain-image.sh
mkdir -p tmp/images
docker run --rm   -v ./scripts:/scripts:ro -v ./tmp/images:/images:rw  -v ./tar:/tar:rw -it container  /scripts/create-plain-image.sh "${IMAGE_SIZE}" "/images/${IMAGE_FILE}" "/tar/" 

# encrypt the ext4 image, converting to LUKS format,
# executing scripts/encrypt-image.sh
echo -n "${LUKS_PASS}" > tmp/images/pass.txt
docker run --rm   -v ./scripts:/scripts:ro -v ./tmp/images:/images:rw  -it container  /scripts/encrypt-image.sh "${IMAGE_SIZE}" "/images/${IMAGE_FILE}" "/images/pass.txt"

