#!/bin/bash
#
# roda.sh
#
# Executa todos os arquivos .afl da pasta afl utilizando o script monitora



DELAY=300

FOLDER=$(date +%s)
FOLDER="dados/${FOLDER}"
AFL_FOLDER="afl"

mkdir -p "$FOLDER"

exec &> $FOLDER/log.txt

for f in afl/*.afl; do 
	if [ ! -f "$f" ]; then
		echo "Arquivo nao encontrando para loop";
		exit
	fi
	OUT=$(basename $f)
	OUT="${FOLDER}/${OUT}.csv"
	echo "Processing $f at `date` (`date +%s`)."
	echo "time ./monitora.sh $OUT roda_iquery.sh $f"
	time ./monitora.sh $OUT iquery_wrapper.sh $f
	echo "Finished $f at `date` (`date +%s`)."
	sleep $DELAY
	echo
	echo
done


