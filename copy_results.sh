#!/bin/bash

for i in `seq 5`; do
    mkdir $i;
    mv results-${i}-*/* $i;
done

rmdir results-*
