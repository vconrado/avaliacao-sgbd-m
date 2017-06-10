#!/bin/bash

DELTA=60
WIDTH=1163
OUTDIR="./img"

if [ "$#" -ne 1 ]; then
    echo "Usage: `basename $0` time_file.csv"
    exit 1
fi
FILE=$1

if [ ! -f "$1" ]; then
    echo "'$1' is not a file"
    exit 2
fi
OUTDIR="$OUTDIR/`basename $FILE`"

if [ ! -d "$OUTDIR" ]; then
    mkdir -p $OUTDIR
fi 

if [ ! -d "$OUTDIR" ]; then
    echo "Was not possible to create '$OUTDIR'"
    exit 3
fi




STIME=$(cat $FILE | cut -d ',' -f 1)
PERIOD=$(cat $FILE | cut -d ',' -f 3)
PERIOD=`expr $PERIOD + $DELTA`

#for g in 840 791 834 824 791 834; do
## avalilable memory 766 791 798 805 812 819
# esensing available memory 825
# cpus user time 834 835 836 837 838
# cpu usage by process 840 841 842 843 844
# Esensing CPU user time 822
# Esensing Incoming network traffic on eth0 831
# Esensing Outgoing network traffic on eth0 832
# Memory rss usage by process 852 853 854 855 856
# Disc sectors written per seconds 828 863 864 865 866
# Disc sectors read per seconds 863 870 872 873 874
for g in  825 834 835 836 837 838 840 841 842 843 844 822 831 832 852 853 854 855 856 828 863 864 865 866 863 870 872 873 874; do
    URL="http://localhost:8765/zabbix/chart2.php?graphid=${g}&period=${PERIOD}&stime=${STIME}&width=$WIDTH"
        wget "$URL" -O $OUTDIR/${g}.png
done

cp $FILE $OUTDIR

