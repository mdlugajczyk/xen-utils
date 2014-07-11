#!/bin/bash

if [ $# -ne 3 ]
then
    echo "USAGE: $0 scheduler output title";
    exit 1;
fi

scheduler=$1
output=$2
title=$3

gnuplot -e "set title '$title'; set terminal png; set output '$output';set key left top; set style fill solid; set xlabel 'benchmark'; set ylabel 'time[s]'; plot '2_vm_per_cpu/$scheduler/result.dat' using 2:xtic(1) with histogram title '2 VMs per CPU', '3_vm_per_cpu/$scheduler/result.dat' using 2:xtic(1) with histogram title '3 VM per CPU', '4_vm_per_cpu/$scheduler/result.dat' using 2:xtic(1) with histogram title '4 VMs per CPU'"
