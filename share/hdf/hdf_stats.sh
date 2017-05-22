#!/bin/bash
#
# Cria os arquivos com a lista de de arquivos HDF que existem nos discos selecionados
# Gera seguintes arquivos dentro da pasta $DIR
#	- hdf.files.doys: com a lista de dias únidos dos arquivos
#	- hdf.files.hv: lista com as celulas únidas ocupadas pelos arquivos
#	- hdf.<dir>·partial: lista de arquivos hdf do diretório <dir>
#	- hdf.files: lista consolidada de todos os arquivos hdf (todos os <dir>'s)


DIR=./data

HDF_COL_SIZE=4800
HDF_ROW_SIZE=4800

echo "Buscando arquivos ..."
find /disks/d14 -name "*.hdf" | sort > $DIR/hdf.files.d14.partial
find /disks/d15 -name "*.hdf" | sort > $DIR/hdf.files.d15.partial

echo "Agrupando arquivos ..."
cat $DIR/*.partial | sort | uniq > $DIR/hdf.files

#cat $DIR/hdf.files | cut -d '.' -f 2 | sort | uniq > $DIR/hdf.files.doys
#cat $DIR/hdf.files | cut -d '.' -f 3 | sort | uniq > $DIR/hdf.files.hv

rm -f $DIR/hdf.files.csv
echo "Gerando do csv ..."
while read line; do
    FILE_DIR=$(dirname $line)
    FILE=$(basename $line)
    AYEARDOY=$(echo $FILE | cut -d '.' -f 2)
    YEAR=${AYEARDOY:1:4}
    YY=${AYEARDOY:3:2}
    DOY=${AYEARDOY:5:3}
    HV=$(echo $FILE | cut -d '.' -f 3)
    H=${HV:1:2}
    V=${HV:4:2}
    let COL_START="${H#0}*${HDF_COL_SIZE}"
    let COL_END="${COL_START}+${HDF_COL_SIZE}-1"
    let ROW_START="${V#0}*${HDF_ROW_SIZE}"
    let ROW_END="${ROW_START}+${HDF_ROW_SIZE}-1"
    #           2     ,     3            ,     4      ,   5      ,    6       ,  7       , 8    , 9    
    echo "${AYEARDOY},${FILE_DIR}/${FILE},${COL_START},${COL_END},${ROW_START},${ROW_END},${DOY},${YEAR}" >> $DIR/hdf.files.csv
done < $DIR/hdf.files

echo "Ordenando linhas do csv ..."
sort $DIR/hdf.files.csv > $DIR/hdf.files_sorted.csv
rm $DIR/hdf.files.csv
mv $DIR/hdf.files_sorted.csv $DIR/hdf.files.csv

echo "Numerando linhas ..."
COUNT=0
while read line; do
    echo "$COUNT,$line" >> $DIR/hdf.files.numered.csv
    COUNT=$(($COUNT + 1)) 
done < $DIR/hdf.files.csv



echo "Quebrando csv por ano ..."
cd $DIR
for ano in $(seq 2000 2016); do 
    grep ${ano}\$ hdf.files.numered.csv > hdf.files.${ano}.csv; 
done
cd ..

echo "Done !!!"
