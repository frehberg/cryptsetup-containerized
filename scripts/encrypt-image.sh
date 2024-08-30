#!/bin/sh -ex

IMAGE_SIZE="$1"
IMAGE_FILE="$2"
PASS_FILE="$3"
LUKS_HEADER_SIZE=32
PAYLOAD_SIZE=$(( $IMAGE_SIZE - $LUKS_HEADER_SIZE))

echo ">>> Converting to encrypted LUKS image $IMAGE_FILE"
echo ">>> Passphrase File: $PASS_FILE ($(cat $PASS_FILE | wc -c))"
echo ">>> Image Size [MB]: $IMAGE_SIZE"
echo ">>> LUKS Header Size [MB]: $LUKS_HEADER_SIZE"
echo ">>> File System Size [MB]: $PAYLOAD_SIZE"
echo ">>> Max Update Image Size [MB]: $PAYLOAD_SIZE"
## read https://mail.google.com/mail/u/0/#search/cryptset/FMfcgzQVxbjQgTPFlqlQfRQLMMHpXKtB

echo ">>> Verifying ${IMAGE_FILE}"
if ! e2fsck -f ${IMAGE_FILE}; then
     echo "Error! Not an ext2/3/4 file system: ${IMAGE_FILE}"
     exit 1 
fi

## shrink the ext4 file system, reserving space for LUKS_HEADER
resize2fs -p  ${IMAGE_FILE}  "${PAYLOAD_SIZE}M"

## ensure 32MB padding bytes at end of image file 
truncate --size "${IMAGE_SIZE}M" ${IMAGE_FILE}

cat $PASS_FILE | /usr/sbin/cryptsetup reencrypt  --new  --disable-locks  --reduce-device-size "${LUKS_HEADER_SIZE}M" ${IMAGE_FILE}
