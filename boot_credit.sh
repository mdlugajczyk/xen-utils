#!/bin/bash

function set_credit {

    ssh $1 "sudo sed -i 's/sched=cosch/sched=credit/' /etc/default/grub && sudo update-grub && sudo reboot"
}

for host in $(cat hosts); do
    set_credit "master@$host"
done
