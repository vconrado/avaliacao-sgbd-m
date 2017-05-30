#!/bin/bash

exec >> /home/scidb/vconrado/avaliacao-sgbd-m/scidb/test/load/logs/test.log 2>&1 

/home/scidb/vconrado/avaliacao-sgbd-m/share/tests/monitora.sh data/test.csv /home/scidb/vconrado/avaliacao-sgbd-m/scidb/test/load/load2scidb.sh /home/scidb/vconrado/avaliacao-sgbd-m/scidb/test/load/hdf.files.test.csv
