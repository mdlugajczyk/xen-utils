#!/bin/bash

if [ $# -ne 1 ]
then
    echo "Usage: $0 password";
    exit 1;
fi

PASS=$1

for node in 1 2 3 4; do
    echo $PASS | sudo -S /usr/local/sbin/node_power-marcin.sh "compute-02$node" --off
    echo $PASS | sudo -S /usr/local/sbin/node_setboot-marcin.sh "compute-02$node" ubuntu-trusty-install-marcin
    echo $PASS | sudo -S /usr/local/sbin/node_power-marcin.sh "compute-02$node" --on
done
