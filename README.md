Cryptsetup Containerized

Encrypting an File System inside a Container without extended container privileges.

When building a linux system with kernel and root system with Yocto or Buildroot, one might feel the need for an encrypted file system.
During the build process the plain root files system shall be transformed into an encrypted file system using the tool 'cryptsetup'.

Commonly the tool 'cryptsetup' is using kernel features to create and write encrypted block dvices aka file systems.
But, being executed within a controlled environment of a container, the access to these kernel features shall be blocked, 
causing the cryptsetup operations to fail.

A simple solution might be to grant extended privileges to the running container; this way granting the container the access to kernel features. 
But this is opening a can of worms on the container host machine in terms of security.

This PoC demonstrates how to create encrypted file systems within a container using cryptsetup, without extended container privileges.
