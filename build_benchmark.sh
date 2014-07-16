#!/bin/bash

USER=$1
NODE=$2
SUITE_DEF=$3
MACHINEFILE=$4

BENCH_DIR=NPB3.3.1
CLASS=B

if [ $# -ne 4 ]
then
    echo "Usage: $0 user-name node-name suite_def machinefile"
    exit 1;
fi

function build_benchmarks {
    ssh -oStrictHostKeyChecking=no $USER@$NODE "rm -rf ~/bin"

    for host in $(cat $MACHINEFILE); do
    	ssh -oStrictHostKeyChecking=no $USER@$host "rm -rf ~/bin"
    done

    scp benchmark/NPB3.3.1.tar.gz $USER@$NODE:
    ssh $USER@$NODE "rm -rf $BENCH_DIR && tar zxvf $BENCH_DIR.tar.gz"
    scp $SUITE_DEF $USER@$NODE:~/$BENCH_DIR/NPB3.3-MPI/config/suite.def
    scp benchmark/make.def $USER@$NODE:~/$BENCH_DIR/NPB3.3-MPI/config/make.def
    ssh $USER@$NODE "cd $BENCH_DIR/NPB3.3-MPI; make suite; mv bin ~/"
    scp $MACHINEFILE $USER@$NODE:machinefile

    for host in $(cat $MACHINEFILE); do
    	ssh -oStrictHostKeyChecking=no $USER@$host "mkdir ~/bin"
    	ssh -oStrictHostKeyChecking=no $USER@$NODE "ssh $host -oStrictHostKeyChecking=no 'ls'" >> /dev/null # add ssh key to avoid key validation error
    	scp -oStrictHostKeyChecking=no $USER@$NODE:~/bin/* $USER@$host:~/bin
    done
}

build_benchmarks
