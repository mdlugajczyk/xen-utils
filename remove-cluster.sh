#!/bin/bash

function remove_disk_and_cfg {
    echo "Removing cluster at host: $1"
   ssh $1 'for vm in $(sudo xl list |grep mpi_node |awk '\''{print $1}'\''); do sudo xl destroy $vm; done '
    ssh $1 "rm mpi_node*.cfg"
}

remove_disk_and_cfg master@compute-021
remove_disk_and_cfg master@compute-022
remove_disk_and_cfg master@compute-023
remove_disk_and_cfg master@compute-024


