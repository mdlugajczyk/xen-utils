#!/bin/bash

function set_cosch {

    ssh $1 "sudo sed -i 's/sched=credit/sched=cosch/' /etc/default/grub && sudo update-grub && sudo reboot"
}

set_cosch master@compute-021
set_cosch master@compute-022
set_cosch master@compute-023
set_cosch master@compute-024
