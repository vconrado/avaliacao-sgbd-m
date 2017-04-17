#!/bin/bash
#
# Roda o iquery passando o arquivo $1 passado como paramentro
#

function usage() {
    echo "Usage: `basename $0` filename.afl"
}

if [ ! -f "$1" ]; then
	echo "File $1 not found!"
    usage
    exit
fi

iquery -a -f $1
