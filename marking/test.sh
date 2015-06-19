#!/bin/bash

if [ -z "$1" ] ; then
    echo "Usage: $0 student-dir"
    exit 1
fi

S="$1"

D="`mktemp -d`"
echo "Using $D"

function copy_temp_to_marked {
    dest=$MARKED/`basename $S`
    rm -rf $dest
    cp -rp $D $dest && \
    rm -rf $D && \
    echo "Copied $D to $dest"
}

MARKED=~/comp3301-2011/a1/marked_outputs
PTH="pth-2.0.7-preempt"
DIST=~/comp3301-2011/a1/$PTH/
BF="$D/build_output.txt"
TO="$D/test_output.txt"
PF="$D/a1.patch"

function die {
    echo "Error: $1" >>$BF
    popd >/dev/null 2>&1 # may not have anything on the dirstack
    copy_temp_to_marked
    exit 3
}

echo "Building solution for `basename $S`" >>$BF
echo " (temp dir is $D)" >>$BF

if [ ! -d $S/$PTH ] ; then
    die "no $PTH directory found in repository"
fi

cp -rp $S/$PTH $D
cp -p "build-pth.sh" $D
cp -p thread_tests/{harness,timeout,busy,combo,order} $D

pushd $D >/dev/null

rm -f $BF $TO $PF
mkdir logs

# clean up the build dir
if [ -f $PTH/Makefile ] ; then
    echo "$PTH not clean, running distclean" >>$BF
    make -C $PTH distclean >>$BF 2>&1
fi
find $PTH -name build-pth.sh -exec rm {} \; >>$BF 2>&1
echo >>$BF

# diff the changes
diff -ubr $DIST pth-2.0.7-preempt/ | grep -v 'Only in' >>$PF 2>&1
echo "Generated diff against dist (`wc -l $PF | awk '{print $1}'` lines)" >>$BF
echo >>$BF

# build pth - this should produce a shared library
chmod +x $PTH/configure >>$BF 2>&1
./build-pth.sh >>$BF 2>&1 || die "compile failed"
if [ ! -r "$PTH/lib/libpth.so" ] ; then
    die "no shared library produced"
fi
echo "Library appears to have been built correctly" >>$BF
echo >>$BF

function capture_log {
    # try each combination for sched.log
    for l in "sched.log" "$PTH/sched.log" ; do
        if [ ! -f $l ] ; then
            echo "sched.log doesn't exist as $l, trying next.." >>$TO
            continue
        else
            cp -p $l logs/$1.log
            echo "sched.log found at $l - captured as logs/$1.log" >>$TO
            return
        fi
    done
    echo "Could not find sched.log after test.." >>$TO
}

function run_test {
    n=$1
    p=$2
    shift 2
    echo "Running test $n through harness ($p $@)" >>$TO
    LD_LIBRARY_PATH=$PTH/lib ./harness $p $@ >>$TO 2>&1
    capture_log $n
}

# run the tests to grab scheduling output
echo "Test output for student `basename $S`" >>$TO
echo >>$TO
echo "Testing scheduler log output" >>$TO
run_test busy_1 ./busy 1
echo "--" >>$TO
run_test busy_10 ./busy 10
echo "--" >>$TO
run_test combo_1 ./combo
echo "--" >>$TO
run_test ordering ./order
echo "--" >>$TO

# and we're done
echo "Finished testing scheduler log output" >>$TO
rm -f build-pth.sh timeout harness busy combo order *.log $PTH/*.log
popd >/dev/null
copy_temp_to_marked

exit 0
