 #!/bin/bash

function remove_vm_and_cfg {
    echo "Removing cluster at host: $1"
    ssh $1 'for vm in $(sudo xl list |grep mpi_node |awk '\''{print $1}'\''); do sudo xl shutdown -w $vm; done '
    ssh $1 "rm mpi_node*.cfg"
}

remove_vm_and_cfg master@compute-021 &
remove_vm_and_cfg master@compute-022 &
remove_vm_and_cfg master@compute-023 &
remove_vm_and_cfg master@compute-024 &
wait


