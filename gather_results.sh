#!/bin/bash

if [ $# -ne 1 ]
then
    echo "USAGE: $0 dir";
    exit 1;
fi

DIR=${1%/}

for file in $(ls $DIR/1); do
    for i in `seq 5`; do
	grep -a "Time in seconds" $DIR/$i/$file >> $DIR/tmp_$file
    done
    cut -c19- $DIR/tmp_$file > $DIR/tmp2_$file
    sum=$(awk '{s+=$0} END {print s}' $DIR/tmp2_$file) # >> $DIR/total_$file
    avg=$(echo "$sum / 5" | bc -l)
    echo "$file, $avg" >> "$DIR/result.dat"
    sed -i "s/result_//" "$DIR/result.dat"
done
