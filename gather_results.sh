#!/bin/bash

if [ $# -ne 1 ]
then
    echo "USAGE: $0 dir";
    exit 1;
fi

DIR=${1%/}

for file in $(ls $DIR/1); do
    grep "Time in seconds" $DIR/1/$file >> $DIR/tmp_$file
    grep "Time in seconds" $DIR/2/$file >> $DIR/tmp_$file
    grep "Time in seconds" $DIR/3/$file >> $DIR/tmp_$file
    grep "Time in seconds" $DIR/4/$file >> $DIR/tmp_$file
    grep "Time in seconds" $DIR/5/$file >> $DIR/tmp_$file
    cut -c19- $DIR/tmp_$file > $DIR/tmp2_$file
    sum=$(awk '{s+=$0} END {print s}' $DIR/tmp2_$file) # >> $DIR/total_$file
    avg=$(echo "$sum / 5" | bc -l)
    echo "$file, $avg" >> "$DIR/result.dat"
    # rm $DIR/tmp_$file
    # rm $DIR/tmp2_$file
    sed -i "s/result_//" "$DIR/result.dat"
done
