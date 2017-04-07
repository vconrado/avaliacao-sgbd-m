#!/bin/bash

DIR=./data

find /disks/d14 -name "*.hdf" | sort > $DIR/hdf.files.d14.partial
find /disks/d15 -name "*.hdf" | sort > $DIR/hdf.files.d15.partial

cat $DIR/*.partial | sort | uniq > $DIR/hdf.files


cat $DIR/hdf.files | cut -d '.' -f 2 | sort | uniq > $DIR/hdf.files.doys
cat $DIR/hdf.files | cut -d '.' -f 3 | sort | uniq > $DIR/hdf.files.hv

