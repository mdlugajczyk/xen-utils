#!/bin/bash

NODES=4
PASS=$1
USER=master
VM_REGISTRATION_FILE=~/registered_ips

if [ $# -ne 1 ]
then
    echo "Usage: $0 password";
    exit 1;
fi

function wait_for {
    eval $1
    while [ $? -ne 0 ]
    do
	sleep 1;
	eval $1
    done
}

function wait_for_host {
    wait_for "ssh $1 'ls' >> /dev/null"
}

function wait_for_all_hosts {
    for i in `seq 4`; do
	wait_for_host "master@compute-02$i"
    done
}

function for_each_host {
    local cmd=$1
    for node in `seq $NODES`; do
	ssh $USER@"compute-02$node" $cmd
    done
}

function create_config {
    local memory=$3
    local file_name="mpi_node_${2}.cfg"
    echo "disk = ['file:/home/master/disk_mpi_${2}.img,xvda,w']" > $file_name
    echo "vif = ['bridge=virbr0']" >> $file_name
    echo "memory = $memory" >> $file_name
    echo "name = 'mpi_node_${2}'" >> $file_name
    echo "vcpu = 1" >> $file_name
    echo "cpus = '$1'" >> $file_name
    echo "bootloader = 'pygrub'" >> $file_name
    echo "on_crash = 'restart'" >> $file_name
}

function create_config_files {
    local first_cpu=$1
    local last_cpu=$2
    local group_id=$3
    local memory=$4

    for cpu in `seq $first_cpu $last_cpu`; do
	create_config $cpu "${group_id}_${cpu}" $memory
    done
}

function setup_mpi_group {
    local group_id=$1
    local exp_id=$2
    local first_cpu=$3
    local last_cpu=$4
    local memory=$5
    local num_vms=$(echo "$NODES*($last_cpu-$first_cpu+1)" | bc)
    echo $num_vms

    create_config_files $first_cpu $last_cpu $group_id $memory
    
    for node in `seq $NODES`; do
	echo "Building cluster at node $node..."
    	./create-mpi-cluster.sh "master@compute-02$node" $first_cpu $last_cpu $memory $group_id >> /dev/null &
    done
    wait
    echo "Every node is ready!"
    echo "Waiting for vms to register"
    wait_for "wc -l $VM_REGISTRATION_FILE |grep $num_vms"
    echo "All vms registered!"
}

function setup_experiment {
    local vm_per_cpu=$1
    local suite_def=$2
    ./remove-cluster.sh
    for i in `seq $vm_per_cpu`; do
	rm $VM_REGISTRATION_FILE
	echo "CREATING GROUP $i"
	setup_mpi_group $i 2 1 3 400
	mv $VM_REGISTRATION_FILE machinefiles/machinefile-${i}
    done

    for i in `seq $vm_per_cpu`; do
    	./build_benchmark.sh $USER $(head -n 1 machinefiles/machinefile-${i}) $suite_def machinefiles/machinefile-${i} >> /dev/null &
    done
    wait
    echo "All benchmarks are build"
}

function run_suite {
    local group_id=$1
    local suite_def=$2
    local results_dir=$3
    local host=$(head -n 1 machinefiles/machinefile-${group_id})

    for iteration in `seq 5`; do
    	mkdir "${results_dir}/${iteration}"
    	while read bench; do
    	    bin=$(echo $bench | awk '{print $1}')
    	    class=$(echo $bench | awk '{print $2}')
    	    nprocs=$(echo $bench | awk '{print $3}')
    	    name="${bin}.${class}.${nprocs}"
    	    ssh $USER@$host "mpirun -n $nprocs -machinefile machinefile ./bin/${name} > result_${name}_${group_id}" < /dev/null
    	    scp $USER@$host:result_${name}_${group_id} "${results_dir}/${iteration}/"
    	done < $suite_def
    done

    ./gather_results.sh ${results_dir}
}

function run_experiment {
    local vm_per_cpu=$1
    local suite_def=$2
    local name=$3
    local results=$4
    setup_experiment $vm_per_cpu $suite_def
    for i in `seq $vm_per_cpu`; do
    	mkdir -p "${results}/${name}/group_${i}"
    	run_suite $i $suite_def "${results}/${name}/group_${i}" &
    done
    wait
}

function run_experiment_credit {
    local results=$1
    ./boot_credit.sh
    ./reboot.sh $PASS
    wait_for_all_hosts
    for time_slice in 30 5 1; do
	for_each_host "sudo xl sched-credit -s -t ${time_slice}"
	for vm in 1 2 3 4; do
	    echo "time_slice: $time_slice  vm: $vm  ${results}/${vm}_per_cpu/"
	    run_experiment $vm "benchmark/suite.def.4nodes" "credit_${time_slice}" "${results}/${vm}_per_cpu/"
	done
    done
}

function run_experiment_robin {
    local results=$1
    local time_slice=5
    for vm in 1 2 3 4; do
	./remove-cluster.sh
	./boot_credit.sh
	./reboot.sh $PASS
	wait_for_all_hosts
	echo "time_slice: $time_slice  vm: $vm  ${results}/${vm}_per_cpu/"
	run_experiment $vm "benchmark/suite.def.4nodes" "robin_${time_slice}" "${results}/${vm}_per_cpu/"
    done
}

run_experiment_credit "experiment-results"
run_experiment_robin "experiment-results"
