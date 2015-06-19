#!/bin/bash

if [ "$1" = "" ] ; then
    echo "Usage: $0 path_to_pth_lib"
    exit 1
fi

if [ ! -f a1test ] ; then
    echo "a1test binary does not exist"
    exit 2
fi

for i in cases/*.dat ; do
    LD_LIBRARY_PATH=$1 ./a1test $i
done
