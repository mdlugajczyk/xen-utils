#!/bin/bash

PASS=$1
SCRIPT=on-node.sh

if [ $# -ne 1 ]
then
    echo "Usage: $0 password";
    exit 1;
fi

function setup {
    sshpass -p $PASS ssh -oStrictHostKeyChecking=no $1 'mkdir ~/.ssh'
    sshpass -p $PASS scp ~/.ssh/id_rsa.pub $1:~/.ssh/authorized_keys
    sshpass -p $PASS scp ~/.ssh/id_rsa.pub $1:~/.ssh/
    sshpass -p $PASS scp ~/.ssh/id_rsa $1:~/.ssh/
    sshpass -p $PASS scp $SCRIPT $1:~/
    ssh $1 "echo '$PASS' | sudo -S sh $SCRIPT"
}

setup master@compute-021
setup master@compute-022
setup master@compute-023
setup master@compute-024
