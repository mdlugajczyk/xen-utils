#!/bin/bash

if [ $# -ne 1 ]
then
    echo "Usage: $0 password";
    exit 1;
fi

function wait_for_ssh {
    $?=1

    while [ $? -ne 0 ]
    do
	ssh $1 "ls";
    done
}

PASS=$1

echo "Installing system..."
./install-system.sh $PASS

for node in 1 2 3 4; do
    echo "Waiting for node $node to come online"
    echo $PASS | sudo -S /usr/local/sbin/node_power-marcin.sh "compute-02$node" --wait-until-off
done

echo "Turning on all nodes"
./turn_on.sh $PASS


echo "Waiting for nodes to become sshable"
wait_for_ssh master@compute-021
wait_for_ssh master@compute-022
wait_for_ssh master@compute-023
wait_for_ssh master@compute-024


echo "setting up all nodes"
./setup_nodes.sh $PASS

echo "playbook"
ansible-playbook ~/xen/xen-playbook/xen.yml -i ~/xen/xen-playbook/hosts
