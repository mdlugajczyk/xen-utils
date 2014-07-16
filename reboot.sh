#!/bin/bash

PASS=$1

if [ $# -ne 1 ]
then
    echo "Usage: $0 password";
    exit 1;
fi

for i in `seq 4`; do
    echo "$PASS" | sudo -S /usr/local/sbin/node_power-marcin.sh "compute-02$i" --off
    echo "$PASS" | sudo -S /usr/local/sbin/node_power-marcin.sh "compute-02$i" --on
done

# ./exec_cmd.sh master@compute-021 "sudo reboot"
# ./exec_cmd.sh master@compute-022 "sudo reboot"
# ./exec_cmd.sh master@compute-023 "sudo reboot"
# ./exec_cmd.sh master@compute-024 "sudo reboot"
