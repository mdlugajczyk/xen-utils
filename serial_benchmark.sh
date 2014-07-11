#!/bin/bash

NODE=$1
CLASS=$2
BENCH_DIR=/home/master/NPB3.1-MZ/NPB3.1-MZ-SER
if [ $# -ne 2 ]
then
    echo "Usage: $0 node-name class";
    exit 1;
fi

for bench in bt sp lu; do
    ssh master@$NODE "cd $BENCH_DIR; cp config/make.def.template config/make.def; make $bench-mz CLASS=$CLASS; ./bin/$bench-mz.$CLASS > $bench-$CLASS-result"
    scp master@$NODE:$BENCH_DIR/$bench-$CLASS-result $NODE-$bench-$CLASS-result
done

# ssh master@$NODE "cd $BENCH_DIR; make sp-mz CLASS=$CLASS; ./bin/sp-mz.$CLASS >> sp-$CLASS-result"
# ssh master@$NODE "cd $BENCH_DIR; make lu-mz CLASS=$CLASS; ./bin/lu-mz.$CLASS >> lu-$CLASS-result"
# scp master@NODE:$BENCH_DIR/bt-$CLASS-result $NODE-sp-$CLASS-result
# scp master@NODE:$BENCH_DIR/bt-$CLASS-result $NODE-lu-$CLASS-result
