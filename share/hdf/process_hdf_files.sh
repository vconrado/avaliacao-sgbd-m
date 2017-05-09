#!/bin/bash

HDF_COL_SIZE=4800
HDF_ROW_SIZE=4800
TIME_DB_DIR=/tmp/time_db_dir
COLL_NAME="mod13q1_all"
HDF_STAT_FILES_DIR="../../share/hdf/data"

mkdir -p $TIME_DB_DIR
if [ ! -d $TIME_DB_DIR ]; then
	echo "Was not possible to create $TIME_DB_DIR"
	exit
fi

find $TIME_DB_DIR -name "*.day" -exec rm '{}' \;

# prepare time axis
DAY=0
while read line; do
	echo $DAY > ${TIME_DB_DIR}/${line}.day
	let DAY="${DAY#0}+1"
done < $HDF_STAT_FILES_DIR/hdf.files.doys

# calculate tile position
while read line; do
	DIR=$(dirname $line)
	FILE=$(basename $line)
	DB_DAY=$(echo $FILE | cut -d '.' -f 2)
	DAY=$(cat ${TIME_DB_DIR}/${DB_DAY}.day)
	HV=$(echo $FILE | cut -d '.' -f 3)
	H=${HV:1:2}
	V=${HV:4:2}
        let COL_START="${H#0}*${HDF_COL_SIZE}"
	let COL_END="${COL_START}+${HDF_COL_SIZE}-1"
        let ROW_START="${V#0}*${HDF_ROW_SIZE}"
	let ROW_END="${ROW_START}+${HDF_ROW_SIZE}-1"
	echo "rasql -q 'UPDATE $COLL_NAME as c set c[$COL_START:$COL_END, $ROW_START:$ROW_END,$DAY:$DAY] assing inv_hdf(\$1)' --file $DIR/$FILE --mdddomain [$COL_START:$COL_END,$ROW_START:$ROW_END,$DAY:$DAY] --mddtype mod13q1_str --user rasadmin --passwd rasadmin"
#	echo "$DIR $FILE [$COL_START:$COL_END, $ROW_START,$ROW_END, $DAY]"
done < $HDF_STAT_FILES_DIR/hdf.files


rm -rf $TIME_DB_DIR		
