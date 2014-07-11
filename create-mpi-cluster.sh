#!/bin/bash

NODE=$1
VM_PER_CPU=$2
IMAGE_NAME="mpi-ip.img"
CPUS=3
MEMORY=$(echo "7000/($CPUS*$VM_PER_CPU)" | bc)

if [ $# -ne 2 ]
then
    echo "Usage: $0 node-name vm-per-cpu";
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

#scp ~/images/$IMAGE_NAME $NODE:

for cpu in `seq $CPUS`; do
    for vm in `seq $VM_PER_CPU`; do
	node=${cpu}_${vm}
	echo "coyping disk for node $node..."
	ssh $NODE "if [ ! -f disk_mpi_$node.img ]; then cp $IMAGE_NAME disk_mpi_$node.img; fi"
	echo "creating config for node $node..."
	create_config $cpu $node
	scp "mpi_node_$node.cfg" $NODE:
	ssh $NODE "sudo xl create -f 'mpi_node_$node.cfg'"
    done
done

