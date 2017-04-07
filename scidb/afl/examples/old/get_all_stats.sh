#!/bin/bash
#
# Script que roda o script para coleta de estatisticas do Zabbix
#
# Created: 2017-04-04
# Updated: 2017-04-04
#

STAT_DIR="stats"

usage(){
	echo "Usage: `basename $0` DATA_DIR"
}

if [ "$#" -lt 1 ]; then
        usage
	exit
fi

DATA_DIR=$1

if [ ! -d "$DATA_DIR" ]; then
	echo "Directory $DATA_DIR not found!"
	exit
fi

for dir in $DATA_DIR/*/; do 
	if [ -d "$dir" ]; then
		if [ ! -f "$dir/.done" ]; then
			OUT_DIR="${dir}/${STAT_DIR}"
			for file in $dir/*.csv; do 
				if [ -f "$file" ]; then
					dfinal=$(basename $file .afl.csv);
					OUT_DIR="${dir}/${STAT_DIR}/$dfinal"
					if [ ! -d "$OUT_DIR" ]; then
						echo "mkdir -p $OUT_DIR"
						if [ ! -d "$OUT_DIR" ]; then
							echo "Was not possible to create $OUT_DIR"
							#exit
						fi
					fi
					echo "./get_statistics.sh $OUT_DIR $file"
				fi
			done
			touch "$dir/.done"
		else
			echo "Skiping $dir (done)"
		fi
	fi
done

