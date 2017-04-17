#!/bin/bash 
#
# roda.sh
#
# Faz o loop de cada linha do arquivo passado como parametro  chamando o script passado como parametro
#  usando o script monitora.sh. A saída é gravada em $3/timestamp


shopt -s nullglob

function usage() {
    echo "Usage: `basename $0` client_wrapper.sh queries_path out_dir [DELAY]"
}

if [ $# -lt 3 ]; then
    usage
    exit
fi

CLI_WRAPPER=$1
QUERIES_DIR=$2
OUT_DIR=$3

if [ $# -eq 3 ]; then
    DELAY=300
else
    DELAY=$4
fi


echo "Usando $CLI_WRAPPER $QUERIES_DIR $OUT_DIR $DELAY"

FOLDER="$OUT_DIR/$(date +%s)"



mkdir -p "$FOLDER"

#exec &> $FOLDER/log.txt

for f in $QUERIES_DIR/*.afl $QUERIES_DIR/*.rql; do 
	if [ ! -f "$f" ]; then
		echo "Arquivo $f nao encontrando para loop";
		exit
	fi
	OUT=$(basename $f)
    EXTENSION="${f##*.}"
    echo "ext $EXTENSION"
	OUT="${FOLDER}/${OUT}.csv"
	echo "Processing $f at `date` (`date +%s`)."
	echo "time ./monitora.sh $OUT roda_iquery.sh $f"
    time ./monitora.sh $OUT $CLI_WRAPPER $f
    echo "Finished $f at `date` (`date +%s`)."
	sleep $DELAY
	echo
	echo
done


