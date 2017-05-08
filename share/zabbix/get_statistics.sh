#!/bin/bash
#
# Script que coleta as estatísticas do Zabbix passando como entrada um arquivo 
#   ou o horario de inicio e fim
# Created: 2017-02-10 
# Updated: 2017-02-10
#
# Se receber um parametro, considera que é um arquivo
# se receber dois, considera que é horario de inicio e fim

DATABASE=zabbix_esensing
SERVER=127.0.0.1
DELTA=60

echoerr() { 
 echo "$@" 1>&2 
}

if [ "$#" -lt 2 ]; then
    	echoerr "Usage `basename $0`  OUT_FOLDER [file.csv | START_TIME END_TIME]"
	exit
fi

OUT_DIR=$1

if [ "$#" -eq 2 ]; then
    FILE=$2
    if [ ! -f "$FILE" ]; then
       echoerr "File $FILE was not found"
       exit
    fi
    START_TIME=$(cat $FILE | cut -f1 -d',')
    END_TIME=$(cat $FILE | cut -f2 -d',')
else
    START_TIME=$2
    END_TIME=$3
fi

if [ ! -d "$OUT_DIR" ]; then
	echo "Creating Directory $OUT_DIR"
	mkdir -p $OUT_DIR
	if [ ! -d "$OUT_DIR" ]; then
		echoerr "Was not possible to create $OUT_DIR"
		exit		
	fi
fi

START_TIME=`expr $START_TIME - $DELTA`
END_TIME=`expr $END_TIME + $DELTA`

echo "Getting statistics from Zabbix" 
echo "Start time: $START_TIME"
echo "End time: $END_TIME"
echo "Delta: $DELTA"

echo "SELECT DISTINCT i.key_, i.value_type \
	FROM items i \
	INNER JOIN hosts h ON (i.hostid = h.hostid) \
	WHERE h.name LIKE 'esensing-01%' AND i.value_type in (0,3);" | mysql --batch -h $SERVER -D $DATABASE | while read -r key
do
	value_type=$(echo $key | tr -s ' ' | cut -f2 -d ' ')
	key=$(echo $key | tr -s ' ' | cut -f1 -d ' ')
    	
	if [[ $key != *"DISK"* ]] && [ $key != "key_" ]; then
    		FILE_NAME=$(echo $key | tr [], ___)
	    	FILE_NAME="$OUT_DIR/${FILE_NAME}.csv"
    		echo "-------------- $FILE_NAME ----------------"
		if [ $value_type == "0" ]; then
			TABLE="history"
		else
			TABLE="history_uint"
		fi
		
	    	SQL="SELECT \
				h.hostid as hostid, \
				CONCAT('\"', h.name,'\"') as host_name, \
				CONCAT('\"', a.name,'\"') as application_name, \
				i.itemid as itemid, \
				i.value_type as value_type, \
				CONCAT('\"', i.key_,'\"') as item_key, \
				hist.clock as clock, \
				hist.ns as ns, \
				hist.value as value \
			FROM hosts h \
				INNER JOIN items i ON (i.hostid = h.hostid) \
				INNER JOIN $TABLE hist ON (hist.itemid = i.itemid) \
				INNER JOIN items_applications ia on (i.itemid = ia.itemid) \
				INNER JOIN applications a ON (a.applicationid = ia.applicationid) \
			WHERE \
				h.host like 'esensing-0%' AND \
				hist.clock >=$START_TIME AND hist.clock <=$END_TIME AND \
				i.key_ = '$key' AND \
				i.status = 0 \
			ORDER BY h.hostid;" 
		echo -e "$SQL\n\n\n" >> "LOG.sql.txt"
		
	    	mysql --batch -h $SERVER -D $DATABASE -e "$SQL" | tr '\t' ',' >> $FILE_NAME
	fi
done

