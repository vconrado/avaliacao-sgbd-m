#!/bin/bash

# Faz a carga de dados de determinado ano
# run.year.sh 2000

if [[ $# -lt 1 ]]; then
    echo "Usage `basename $0` year"
    return 1
fi


LABEL="$1"


exec >> /home/scidb/vconrado/avaliacao-sgbd-m/scidb/test/load/logs/${LABEL}.log 2>&1 

/home/scidb/vconrado/avaliacao-sgbd-m/share/tests/monitora.sh data/${LABEL}.csv /home/scidb/vconrado/avaliacao-sgbd-m/scidb/test/load/load2scidb.sh /home/scidb/vconrado/avaliacao-sgbd-m/share/hdf/data/hdf.files.${LABEL}.csv
