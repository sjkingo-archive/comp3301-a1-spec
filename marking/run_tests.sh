#!/bin/bash

if [ "$1" = "" ] ; then
    echo "Usage: $0 single-submission-dir" 1>&2
    exit 1
fi

dir="`readlink -f $1`"
DIST="work/pth-2.0.7-preempt-dist"

echo "=== Running diff ==="
diff -ubr $DIST $dir | grep -v 'Only in' > $dir/solution.patch 2>&1
echo

echo "=== Building Pth library ==="
pushd work
rm -f .lib_under_test
ln -s $dir .lib_under_test
./build-pth.sh
echo "=== Build complete"
popd
echo

echo "=== Building test programs ==="
pushd test_programs
make clean all
echo "=== Build complete ==="
#echo
#echo "=== Running tests ==="
#for i in greedy_test1 greedy_test2; do
#    ./$i
#    cat sched.log
#done
#echo "=== Finished running tests ==="
popd
echo

echo "=== File list ==="
for i in build.log solution.patch ; do
    file $dir/$i
done

