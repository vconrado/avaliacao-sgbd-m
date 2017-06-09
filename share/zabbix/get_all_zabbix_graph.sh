!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: `basename $0` dir.times"
    exit 1
fi
DIR=$1

if [ ! -d "$1" ]; then
    echo "'$1' is not a directory"
    exit 2
fi

for d in $DIR/*.csv; do
    ./get_zabbix_graph.sh $d
done
