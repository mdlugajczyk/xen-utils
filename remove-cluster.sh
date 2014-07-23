 #!/bin/bash

function remove_vm_and_cfg {
    echo "Removing cluster at host: $1"
    ssh $1 'sudo xl shutdown -a'
    ssh $1 "rm mpi_node*.cfg"
}

for host in $(cat hosts); do
    remove_vm_and_cfg "master@$host" &
done
wait
sleep 7


