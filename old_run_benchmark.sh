#!/bin/bash

USER=$1
NODE=$2
MACHINEFILE=$3
SUITE_DEF=$4
RESULTS_DIR=$5

BENCH_DIR=NPB3.3.1
CLASS=B

if [ $# -ne 5 ]
then
    echo "Usage: $0 user-name node-name"
    exit 1;
fi

# args: nprocs ben_name results_file results_dir
function run_benchmark {
    ssh $USER@$NODE "mpirun -n $1 -machinefile machinefile ./bin/$2 > $3"
    scp $USER@$NODE:~/$3 $4
}

function build_benchmarks {
    ssh $USER@$NODE "rm -rf ~/bin"

    for host in $(cat benchmark/machinefile); do
    	ssh -oStrictHostKeyChecking=no $USER@$host "rm -rf ~/bin"
    done

    scp benchmark/NPB3.3.1.tar.gz $USER@$NODE:
    ssh $USER@$NODE "rm -rf $BENCH_DIR && tar zxvf $BENCH_DIR.tar.gz"
    scp suite.def.tmp $USER@$NODE:~/$BENCH_DIR/NPB3.3-MPI/config/suite.def
    scp benchmark/make.def $USER@$NODE:~/$BENCH_DIR/NPB3.3-MPI/config/make.def
    ssh $USER@$NODE "cd $BENCH_DIR/NPB3.3-MPI; make suite; mv bin ~/"
    scp benchmark/machinefile $USER@$NODE:

    for host in $(cat benchmark/machinefile); do
    	ssh -oStrictHostKeyChecking=no $USER@$host "mkdir ~/bin || echo 'bin exists'"
    	ssh -oStrictHostKeyChecking=no $USER@$NODE "ssh $host -oStrictHostKeyChecking=no 'ls'" >> /dev/null # add ssh key to avoid key validation error
    	scp -oStrictHostKeyChecking=no $USER@$NODE:~/bin/* $USER@$host:~/bin
    done
}

function configure_benchmarks {
    rm suite.def.tmp
    touch suite.def.tmp
    echo "bt ${bt[1]} ${bt[2]}" >> suite.def.tmp
    echo "cg ${cg[1]} ${cg[2]}" >> suite.def.tmp
    echo "ep ${ep[1]} ${ep[2]}" >> suite.def.tmp
    echo "ft ${ft[1]} ${ft[2]}" >> suite.def.tmp
    echo "is ${is[1]} ${is[2]}" >> suite.def.tmp
    echo "lu ${lu[1]} ${lu[2]}" >> suite.def.tmp
    echo "mg ${mg[1]} ${mg[2]}" >> suite.def.tmp
    echo "sp ${sp[1]} ${sp[2]}" >> suite.def.tmp
}

#args : results_dir
function run_suite {
    results_dir=$1
    mkdir $results_dir
    echo "run!"
    run_benchmark ${bt[2]} "${bt[0]}.${bt[1]}.${bt[2]}" "result_${bt[0]}_${bt[1]}_${bt[2]}" $results_dir
    run_benchmark ${cg[2]} "${cg[0]}.${cg[1]}.${cg[2]}" "result_${cg[0]}_${cg[1]}_${cg[2]}" $results_dir
    run_benchmark ${ep[2]} "${ep[0]}.${ep[1]}.${ep[2]}" "result_${ep[0]}_${ep[1]}_${ep[2]}" $results_dir
    run_benchmark ${ft[2]} "${ft[0]}.${ft[1]}.${ft[2]}" "result_${ft[0]}_${ft[1]}_${ft[2]}" $results_dir
    run_benchmark ${is[2]} "${is[0]}.${is[1]}.${is[2]}" "result_${is[0]}_${is[1]}_${is[2]}" $results_dir
    run_benchmark ${lu[2]} "${lu[0]}.${lu[1]}.${lu[2]}" "result_${lu[0]}_${lu[1]}_${lu[2]}" $results_dir
    run_benchmark ${mg[2]} "${mg[0]}.${mg[1]}.${mg[2]}" "result_${mg[0]}_${mg[1]}_${mg[2]}" $results_dir
    run_benchmark ${sp[2]} "${sp[0]}.${sp[1]}.${sp[2]}" "result_${sp[0]}_${sp[1]}_${sp[2]}" $results_dir

    echo "RESULTS IN DIR: $RESULTS_DIR"
}


configure_benchmarks;
build_benchmarks;
for i in `seq 1 5`; do
    run_suite "results-$i-$RANDOM"
done
