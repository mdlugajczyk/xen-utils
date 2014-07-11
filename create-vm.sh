#!/bin/bash

ISO_NAME=ubuntu.iso
NODE_NAME=node1
MEMORY=1048

wget http://releases.ubuntu.com/14.04/ubuntu-14.04-server-amd64.iso --output-document $ISO_NAME
sudo mkdir /mnt/ubuntu_iso
sudo mount -o loop $ISO_NAME /mnt/ubuntu_iso
sudo cp /mnt/ubuntu_iso/install/initrd.gz /home/master/initrd.gz
sudo cp /mnt/ubuntu_iso/install/vmlinuz /home/master/vmlinuz
sudo umount /mnt/ubuntu_iso
sudo rmdir /mnt/ubuntu_iso

echo "generating disc..."
dd if=/dev/zero of=disk-$NODE_NAME.img bs=1M count=3000

# generate config file

echo "kernel = '/home/master/vmlinuz'" >> ubuntu-$NODE_NAME.cfg
echo "ramdisk = '/home/master/initrd.gz'" >> ubuntu-$NODE_NAME.cfg
echo "disk = ['file:/home/master/disk-$NODE_NAME.img,xvda,w','file:/home/master/$ISO_NAME,xvdc:cdrom,r']" >> ubuntu-$NODE_NAME.cfg
echo "vif = ['bridge=virbr0']" >> ubuntu-$NODE_NAME.cfg
echo "memory = $MEMORY" >> ubuntu-$NODE_NAME.cfg
echo "name = 'ubuntu-$NODE_NAME'" >> ubuntu-$NODE_NAME.cfg
echo "vcpu = 1" >> ubuntu-$NODE_NAME.cfg
