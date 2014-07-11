#!/bin/bash

function set_credit {

    ssh $1 "sudo sed -i 's/sched=cosch/sched=credit/' /etc/default/grub && sudo update-grub && sudo reboot"
}

set_credit master@compute-021
set_credit master@compute-022
set_credit master@compute-023
set_credit master@compute-024
