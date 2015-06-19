#!/bin/bash

if [ "$1" = "" ] ; then
    echo "Usage: $0 submission-dir" 1>&2
    exit 1
fi

dir="`readlink -f $1`"
date="`date '+%Y%m%d%H%M'`"

for i in $dir/comp* ; do
    echo "Building `basename $i` ..."
    pth_dir=$i/pth-*
    #pushd work >/dev/null 2>&1
    #rm -f .lib_under_test
    #ln -s $pth_dir .lib_under_test
    ./run_tests.sh $pth_dir > $i/build.log 2>&1
    ./svn_log.sh `basename $i` > $i/svn.log 2>&1
    #popd >/dev/null 2>&1
done

