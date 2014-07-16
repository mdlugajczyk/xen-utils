#!/bin/bash

NODE=$1
IMAGE_NAME="mpi-ip.img"
FIRST_CPU=$2
LAST_CPU=$3
MEMORY=$4   #$(echo "7000/($CPUS*$VM_PER_CPU)" | bc)
ID=$5

if [ $# -ne 5 ]
then
    echo "Usage: $0 node-name first-cpu last-cpu memory id";
    exit 1;
fi

function create_config {
    file_name="mpi_node_${2}.cfg"
    echo "disk = ['file:/home/master/disk_mpi_${2}.img,xvda,w']" > $file_name
    echo "vif = ['bridge=virbr0']" >> $file_name
    echo "memory = $MEMORY" >> $file_name
    echo "name = 'mpi_node_${2}'" >> $file_name
    echo "vcpu = 1" >> $file_name
    echo "cpus = '$1'" >> $file_name
    echo "bootloader = 'pygrub'" >> $file_name
}

ssh $NODE "ls" |grep $IMAGE_NAME;
if [ $? -eq 1 ]
then
    scp ~/images/$IMAGE_NAME $NODE:
fi

for cpu in `seq $FIRST_CPU $LAST_CPU`; do
    node=${ID}_${cpu}
    ssh $NODE "if [ ! -f disk_mpi_$node.img ]; then cp $IMAGE_NAME disk_mpi_$node.img; fi"
    scp "mpi_node_$node.cfg" $NODE:
    echo "CREATING VM: mpi_node_${node}.cfg"
    ssh $NODE "sudo xl create -f 'mpi_node_${node}.cfg'"
done
