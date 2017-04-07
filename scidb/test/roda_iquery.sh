#!/bin/bash


if [ ! -f "$1" ]; then
	echo "File $1 not found!"
fi

iquery -a -f $1
