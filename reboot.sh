#!/bin/bash

PASS=$1

if [ $# -ne 1 ]
then
    echo "Usage: $0 password";
    exit 1;
fi

for host in $(cat hosts); do
    echo "$PASS" | sudo -S /usr/local/sbin/node_power-marcin.sh $host --off
done

sleep 3;

for host in $(cat hosts); do
    echo "$PASS" | sudo -S /usr/local/sbin/node_power-marcin.sh $host --on
done

# ./exec_cmd.sh master@compute-021 "sudo reboot"
# ./exec_cmd.sh master@compute-022 "sudo reboot"
# ./exec_cmd.sh master@compute-023 "sudo reboot"
# ./exec_cmd.sh master@compute-024 "sudo reboot"
