#!/bin/bash

NPROCS=$3
CLASS=B
NODE=$2
USER=$1
BENCH_DIR=NPB3.3.1
#BENCHMARKS="bt cg dt ep ft is lu mg sp"
BENCHMARKS="dt ep lu"

if [ $# -ne 3 ]
then
    echo "Usage: $0 user-name node-name num-proc";
    exit 1;
fi

cp benchmark/suite.def benchmark/suite.def.tmp
sed -i "s/1/$NPROCS/" benchmark/suite.def.tmp
sed -i "s/S/$CLASS/" benchmark/suite.def.tmp

ssh $USER@$NODE "rm -rf ~/bin"

for host in $(cat benchmark/machinefile); do
    # scp -oStrictHostKeyChecking=no ~/.ssh/id_rsa.pub $USER@$host:~/.ssh
    # scp -oStrictHostKeyChecking=no ~/.ssh/id_rsa $USER@$host:~/.ssh
    ssh -oStrictHostKeyChecking=no $USER@$host "rm -rf ~/bin"
done

scp benchmark/NPB3.3.1.tar.gz $USER@$NODE:
ssh $USER@$NODE "rm -rf $BENCH_DIR && tar zxvf $BENCH_DIR.tar.gz"
scp benchmark/suite.def.tmp $USER@$NODE:~/$BENCH_DIR/NPB3.3-MPI/config/suite.def
scp benchmark/make.def $USER@$NODE:~/$BENCH_DIR/NPB3.3-MPI/config/make.def
ssh $USER@$NODE "cd $BENCH_DIR/NPB3.3-MPI; make suite; mv bin ~/"
scp benchmark/machinefile $USER@$NODE:

for host in $(cat benchmark/machinefile); do
    ssh -oStrictHostKeyChecking=no $USER@$host "mkdir ~/bin || echo 'bin exists'"
    ssh -oStrictHostKeyChecking=no $USER@$NODE "ssh $host -oStrictHostKeyChecking=no 'ls'" >> /dev/null # add ssh key to avoid key validation error
    scp -oStrictHostKeyChecking=no $USER@$NODE:~/bin/* $USER@$host:~/bin
done

RESULTS_DIR=results.$RANDOM
mkdir $RESULTS_DIR
for benchmark in `echo $BENCHMARKS`; do
    name=${benchmark}.${CLASS}.${NPROCS};
    ssh $USER@$NODE "mpirun -n $NPROCS -machinefile machinefile ./bin/$name >> result_$name"
    scp results_$name s210664@central.senbazuru.soe.cranfield.ac.uk:~/xen/setup/$RESULTS_DIR:
done

echo "Results are stored in: $RESULTS_DIR"
# ssh $USER@$NODE 'for bench in $(ls bin); do mpirun -n 16 -machinefile machinefile ./bin/$bench >> result_$bench; done;'


