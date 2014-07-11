#!/bin/bash

HOST=$1
CMD=$2

if [ $# -ne 2 ]
then
    echo "Usage: $0 host cmd";
    exit 1;
fi

ssh $HOST "$CMD"
