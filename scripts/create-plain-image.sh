#!/bin/sh -ex

IMAGE_SIZE="$1"
IMAGE_FILE="$2"
IMAGE_TAR="$3"

echo ">>> Creating plain image $IMAGE_FILE"
echo ">>> Image Size [MB]: $IMAGE_SIZE"

chown -R root:root ${IMAGE_TAR}/*
ls -ld ${IMAGE_TAR}/*
ls -l ${IMAGE_TAR}/bin/

rm -f ${IMAGE_FILE}
truncate --size "${IMAGE_SIZE}M" ${IMAGE_FILE}

mke2fs -t ext4 -j -d ${IMAGE_TAR} ${IMAGE_FILE}

