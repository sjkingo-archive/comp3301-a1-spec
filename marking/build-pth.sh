#!/bin/bash

# Pth build script
# Written by Sam Kingston, 2010-2011

# Change this to the path containing pth - leave off a trailing slash.
# Note you probably shouldn't change this, rather just place the current
# script in the same directory as the tarball.
D="./pth-2.0.7-preempt"

# usage message
if [ "$1" = "--help" ] || [ $# -ge 3 ] ; then
    echo "Usage: $0 [--debug] [--extract]"
    echo "(note that the arguments, if present, must be in the specified order)"
    echo
    echo "This script will build the Pth source tree given (located at $D)"
    echo "For the first run, you should use the --extract argument to create the"
    echo "source tree. --debug will enable Pth's debugging support, but will not"
    echo "create a shared library so you will be unable to use LD_LIBRARY_PATH"
    echo "to link against the library at runtime. Instead, link against the static"
    echo "library at compile-time."
    exit 1
fi

# version
if [ "$1" = "-v" ] ; then
    echo "version 1.5-marking - 2011-09-29 11:12"
    echo "(this version supports preemptive Pth)"
    exit 1
fi

# make sure the directory does exist
if [ ! -d "$D" ] ; then
    echo "Directory $D does not exist. Did you mean to use the --extract argument?"
    exit 2
fi

# make sure the user is specifying the correct version of Pth (preempt)
if [ ! -f "$D/preempt" ] ; then
    echo "You don't seem to be using the preemptive version of Pth. You must download"
    echo "it from the Resources page on the course website and not from any other source."
    exit 3
fi

time (
    pushd $D || exit 3
    rm -f lib/*
    ./configure --prefix=$PWD $ARGS && \
    make && \
    make install
    popd
)
