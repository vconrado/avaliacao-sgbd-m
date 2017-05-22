#!/bin/bash

# Carrega imagens hdf para o scidb a partir da lista em csv no formato
# seq,ayyyydoy,full_path_file_name,h0, hf, v0, vf, yydoy, doy, yyyy
# h0, hf, v0 e vf: representam a quadricula no mapa MODIS
# yydoy é uma referencia ao tempo (dois ultimos digitos do ano + doy)
#
# Este script:
# 1) extrai 11 bandas do arquivo hdf usando hdp
# 2) Junta as bandas usando a aplicação interleaver
# 3) Insere os dados no SciDB usando um array 1D
# 4) Insere os arquivos do array 1D no array 3D
# 5) Apaga o array 1D
# 6) Reperete os passos 1-5 para todos os arquivos apontados no csv
#
#
# Fonte HDP: https://nsidc.org/data/hdfeos/hdf_to_binary.html

TMP_DIR="/disks/d11/hdf_tmp"
HDP="/home/scidb/vconrado/hdf/bin/hdp"
INTERLEAVER="/home/scidb/vconrado/avaliacao-sgbd-m/share/interleaver/interleaver"
ARRAY_1D="mod13q1_vc_1d_temp"
ARRAY_3D="mod13q1_vc_test"
ROW_SIZE=4800
COL_SIZE=4800


if [ $# -lt 1 ]; then
    echo "Usage: $(basename $0) file.csv"
    exit
fi

function HDP_CONVERT {
    LAYER=$1
    FILE_OUT=$2
    FILE_IN=$3
    
    echo "$HDP dumpsds -n \"$LAYER\" -o \"$FILE_OUT\" -b \"$FILE_IN\""

}


INPUT_FILE=$1

if [ ! -f "$INPUT_FILE" ]; then
    echo "Arquivo '$INPUT_FILE' não encontrado"
    exit
fi


while read line; do
    SEQ=$(echo $line | cut -d ',' -f 1)
    #AYYYY=$(echo $line | cut -d ',' -f 2)
    FILE=$(echo $line | cut -d ',' -f 3)
    H0=$(echo $line | cut -d ',' -f 4)
    HF=$(echo $line | cut -d ',' -f 5)
    V0=$(echo $line | cut -d ',' -f 6)
    VF=$(echo $line | cut -d ',' -f 7)
    DOY=$(echo $line | cut -d ',' -f 8)
    YYYY=$(echo $line | cut -d ',' -f 9)

    echo "$FILE $H0 $HF $V0 $VF $YYDOY $DOY $YYYY"
    
    # 1) Extrai bandas
    # ndvi
    LAYER="250m 16 days NDVI"
    FILE_NDVI="${FILE}.ndvi"
    hdp_convert "250m 16 days NDVI" 
    $HDP dumpsds -n "$LAYER" -o "${TMP_DIR}/${FILE_NDVI}" -b "$FILE"

    # evi
    LAYER="250m 16 days EVI"
    FILE_EVI="${FILE}.evi"
    $HDP dumpsds -n "$LAYER" -o "${TMP_DIR}/${FILE_EVI}" -b "$FILE"
    
    # quality
    LAYER="250m 16 days VI Quality"
    FILE_QUALITY="${FILE}.quality"
    $HDP dumpsds -n "$LAYER" -o "${TMP_DIR}/${FILE_QUALITY}" -b "$FILE"
    
    # red
    LAYER="250m 16 days red reflectance"
    FILE_RED="${FILE}.red"
    $HDP dumpsds -n "$LAYER" -o "${TMP_DIR}/${FILE_RED}" -b "$FILE"

    # nir
    LAYER="250m 16 days NIR reflectance"
    FILE_NIR="${FILE}.nir"

    # blue
    LAYER="250m 16 days blue reflectance"
    FILE_BLUE="${FILE}.blue"

    # mir
    LAYER="250m 16 days MIR reflectance"
    FILE_MIR="${FILE}.mir"

    # view_zenith
    LAYER="250m 16 days view zenith angle"
    FILE_VIEW_ZENITH="${FILE}.view_zenith"

    # sun_zenith
    LAYER="250m 16 days sun zenith angle"
    FILE_SUN_ZENITH="${FILE}.sun_zenith"

    # relative_azimuth
    LAYER="250m 16 days relative azimuth angle"
    FILE_RELATIVE_AZIMUTH="${FILE}.relative_azimuth"

    # day_of_year
    LAYER="250m 16 days composite day of the year"
    FILE_DOY="${FILE}.doy"

done < $INPUT_FILE


#iquery -a -q "insert(redimension(apply(mod13q1_vc_1d_test,row_id, 10+i%10, col_id, 20+i/10),mod13q1_vc_test),mod13q1_vc_test);"


