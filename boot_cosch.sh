#!/bin/bash

function set_cosch {

    ssh $1 "sudo sed -i 's/sched=credit/sched=cosch/' /etc/default/grub && sudo update-grub && sudo reboot"
}

for host in $(cat hosts); do
    set_cosch "master@$host"
done
