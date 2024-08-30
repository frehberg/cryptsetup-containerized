# Cryptsetup Containerized

Encrypting an File System inside a Container without extended container privileges.

When building a linux system with kernel and root system with Yocto or Buildroot, one might feel the need for an encrypted file system.
During the build process the plain root files system shall be transformed into an encrypted file system using the tool 'cryptsetup'.

Commonly the tool 'cryptsetup' is using kernel features to create and write encrypted block dvices aka file systems.
But, being executed within a controlled environment of a container, the access to these kernel features shall be blocked, 
causing the cryptsetup operations to fail.

A simple solution might be to grant extended privileges to the running container; this way granting the container the access to kernel features. 
But this is opening a can of worms on the container host machine in terms of security.

This PoC demonstrates how to create encrypted file systems within a container using cryptsetup, without extended container privileges.

The script scripts/create-plain-image.sh is creating a plain ext4 files system within a container. The content of the folder ./tar/ is dumped into the ext4 image.

Aftewards the script scripts/encrypt-image.sh is encrypting this plain ext4 file system within a container, converting into a LUKS partition.

This LUKS partition image can be used now as is, to form a disk image, for example using the tool [genimage](https://github.com/pengutronix/genimage)

## Demonstrator

### Check out 

Check out the code from github with git command, or similar.

```shell
$ git clone https://github.com/frehberg/cryptsetup-containerized.git
$ cd cryptsetup-containerized
```

### Executing Demonstrator

The build.sh script is performing three steps
* Create the docker image from Dockerfile
* Invoke the docker container to create the plain ext4 file system in `tmp/images/rootfs.img` containing the content of the folder `./tar/`
* Invoke the docker container to encrypt the plain4 ext4 file system in place
Finally the encrypted file system image is the file `tmp/images/rootfs.img`
  
```shell
$ ./build.sh
```

Expected Output

```shell
[+] Building 0.9s (9/9) FINISHED                                                     docker:default
 => [internal] load build definition from Dockerfile                                           0.0s
 => => transferring dockerfile: 299B                                                           0.0s
 => [internal] load metadata for docker.io/library/debian:bookworm                             0.8s
 => [internal] load .dockerignore                                                              0.0s
 => => transferring context: 2B                                                                0.0s
 => [1/5] FROM docker.io/library/debian:bookworm@sha256:aadf411dc9ed5199bc7dab48b3e6ce18f8bbe  0.0s
 => CACHED [2/5] RUN apt-get update                                                            0.0s
 => CACHED [3/5] RUN apt-get install -y cryptsetup                                             0.0s
 => CACHED [4/5] RUN apt-get install -y coreutils                                              0.0s
 => CACHED [5/5] RUN apt-get install -y e2fsprogs                                              0.0s
 => exporting to image                                                                         0.0s
 => => exporting layers                                                                        0.0s
 => => writing image sha256:dcd72b2b2fc301f302f822c8d059ed8a4168208f943070f642fad26190d41cf6   0.0s
 => => naming to docker.io/library/container                                                   0.0s
>>> Creating plain image /images/rootfs.img
>>> Image Size [MB]: 4096
drwxrwxr-x 2 root root 4096 Aug 30 13:03 /tar//bin
drwxrwxr-x 2 root root 4096 Aug 30 13:02 /tar//root
total 4
-rwxrwxr-x 1 root root 31 Aug 30 13:03 hello
mke2fs 1.47.0 (5-Feb-2023)
Discarding device blocks: done                            
Creating filesystem with 1048576 4k blocks and 262144 inodes
Filesystem UUID: ed12d820-8824-408a-a711-bbd7e8bbcc0f
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376, 294912, 819200, 884736

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (16384 blocks): done
Copying files into the device: done
Writing superblocks and filesystem accounting information: done 

>>> Converting to encrypted LUKS image /images/rootfs.img
>>> Passphrase File: /images/pass.txt (8)
>>> Image Size [MB]: 4096
>>> LUKS Header Size [MB]: 32
>>> File System Size [MB]: 4064
>>> Max Update Image Size [MB]: 4064
>>> Verifying /images/rootfs.img
e2fsck 1.47.0 (5-Feb-2023)
Pass 1: Checking inodes, blocks, and sizes
Pass 2: Checking directory structure
Pass 3: Checking directory connectivity
Pass 4: Checking reference counts
Pass 5: Checking group summary information
/images/rootfs.img: 14/262144 files (0.0% non-contiguous), 36945/1048576 blocks
resize2fs 1.47.0 (5-Feb-2023)
Resizing the filesystem on /images/rootfs.img to 1040384 (4k) blocks.
The filesystem on /images/rootfs.img is now 1040384 (4k) blocks long.

Finished, time 00m08s, 4080 MiB written, speed 456.7 MiB/s

```
### Verification

Verifying the LUKS Image requires root privileges on the host
```shell
$ ./test-efs-privileged.sh
```
The test script is opening the LUKS image, and mounting the file system. The script should terminate with SUCCESS message.
```
>>> Opening LUKS fs: tmp/images/rootfs.img
>>> Mounting fs: /dev/mapper/efs
>>> Reading fs /tmp/efs-mount
/tmp/efs-mount
/tmp/efs-mount/bin
/tmp/efs-mount/bin/hello
/tmp/efs-mount/root
/tmp/efs-mount/lost+found
-rwxrwxr-x 1 root root 31 Aug 30 15:03 /tmp/efs-mount/bin/hello
bin  lost+found  root
Filesystem      1K-blocks  Used Available Use% Mounted on
/dev/mapper/efs   4013792    36   3789300   1% /tmp/efs-mount
SUCCESS: valid LUKS encrypted file system (efs)
```

