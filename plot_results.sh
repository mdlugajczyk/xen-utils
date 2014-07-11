#!/bin/bash

if [ $# -ne 3 ]
then
    echo "USAGE: $0 dir output title";
    exit 1;
fi

cdir=$1
output=$2
title=$3

gnuplot -e "set title '$title'; set terminal png; set output '$output';set key left top; set style fill solid; set xlabel 'benchmark'; set ylabel 'time[s]'; plot '$cdir/credit_1/result.dat' using 2:xtic(1) with histogram title 'credit 1ms', '$cdir/robin_1/result.dat' using 2:xtic(1) with histogram title 'robin 1ms', '$cdir/credit_5/result.dat' using 2:xtic(1) with histogram title 'credit 5ms', '$cdir/robin_5/result.dat' using 2:xtic(1) with histogram title 'robin 5ms', '$cdir/credit_30/result.dat' using 2:xtic(1) with histogram title 'credit 30ms'"

gnuplot -e "set title '$title'; set terminal png; set output 'no_credit_${output}';set key left top; set style fill solid; set xlabel 'benchmark'; set ylabel 'time[s]'; plot '$cdir/credit_1/result.dat' using 2:xtic(1) with histogram title 'credit 1ms', '$cdir/robin_1/result.dat' using 2:xtic(1) with histogram title 'robin 1ms', '$cdir/credit_5/result.dat' using 2:xtic(1) with histogram title 'credit 5ms', '$cdir/robin_5/result.dat' using 2:xtic(1) with histogram title 'robin 5ms'"

