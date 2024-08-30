FROM debian:bookworm

RUN apt-get update
# install 'cryptsetup' 
RUN apt-get install -y cryptsetup 

# install 'truncate'
RUN apt-get install -y coreutils

# install 'mkfs.ext4', 'resize2fs', 'mke2fs'
RUN apt-get install -y e2fsprogs

ENTRYPOINT [ "/bin/sh" ]
