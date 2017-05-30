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

function hdp_convert {
    LAYER=$1
    FILE_OUT=$2
    FILE_IN=$3
    echo "Extraindo '$LAYER' ..." 
    #echo "$HDP dumpsds -n \"$LAYER\" -o \"$FILE_OUT\" -b \"$FILE_IN\""
    $HDP dumpsds -n "$LAYER" -o "$FILE_OUT" -b "$FILE_IN"
}

INPUT_FILE=$1

if [ ! -f "$INPUT_FILE" ]; then
    echo "Arquivo '$INPUT_FILE' não encontrado"
    exit
fi


#[col_id=0:172799,40,0,row_id=0:86399,40,0,time_id=0:511,512,0]'

#    iquery -a -q "create array mod13q1_vc_3d_test_1 <ndvi:int16,evi:int16,quality:uint16,red:int16,nir:int16,blue:int16,mir:int16,view_zenith:int16,sun_zenith:int16,relative_azimuth:int16,day_of_year:int16> [col_id=0:172799,40,0,row_id=0:86399,40,0,time_id=0:511,512,0];"
#    echo "iquery -a -q \"create array mod13q1_vc_3d_test_1 <ndvi:int16,evi:int16,quality:uint16,red:int16,nir:int16,blue:int16,mir:int16,view_zenith:int16,sun_zenith:int16,relative_azimuth:int16,day_of_year:int16> [col_id=0:172799,40,0,row_id=0:86399,40,0,time_id=0:511,512,0];\""
    echo
START_TIME=$(date +%s)
while read line; do

    START_F_TIME=$(date +%s)
    TIME=$(echo $line | cut -d ',' -f 1)
    FILE=$(echo $line | cut -d ',' -f 2)
    H0=$(echo $line | cut -d ',' -f 3)
    HF=$(echo $line | cut -d ',' -f 4)
    V0=$(echo $line | cut -d ',' -f 5)
    VF=$(echo $line | cut -d ',' -f 6)
    DOY=$(echo $line | cut -d ',' -f 7)
    YYYY=$(echo $line | cut -d ',' -f 8)

    echo "1. Extraindo Layers do arquivo $FILE ..."
    
    # 1) Extrai bandas
    # ndvi
    NDVI_FILE="${TMP_DIR}/$(basename ${FILE}).ndvi"
    hdp_convert "250m 16 days NDVI" "${NDVI_FILE}" "${FILE}"

    # evi
    EVI_FILE="${TMP_DIR}/$(basename ${FILE}).evi" 
    hdp_convert "250m 16 days EVI" "${EVI_FILE}" "${FILE}"
    
    # quality
    QUALITY_FILE="${TMP_DIR}/$(basename ${FILE}).quality"
    hdp_convert "250m 16 days VI Quality" "${QUALITY_FILE}" "${FILE}"

    # red
    RED_FILE="${TMP_DIR}/$(basename ${FILE}).red"
    hdp_convert "250m 16 days red reflectance" "${RED_FILE}" "${FILE}"

    # nir
    NIR_FILE="${TMP_DIR}/$(basename ${FILE}).nir"
    hdp_convert "250m 16 days NIR reflectance" "${NIR_FILE}" "${FILE}"

    # blue
    BLUE_FILE="${TMP_DIR}/$(basename ${FILE}).blue"
    hdp_convert "250m 16 days blue reflectance" "${BLUE_FILE}" "${FILE}"
    
    # mir
    MIR_FILE="${TMP_DIR}/$(basename ${FILE}).mir" 
    hdp_convert "250m 16 days MIR reflectance" "${MIR_FILE}" "${FILE}"
    
    # view_zenith
    VIEW_ZENITH_FILE="${TMP_DIR}/$(basename ${FILE}).view_zenith"
    hdp_convert "250m 16 days view zenith angle" "${VIEW_ZENITH_FILE}" "${FILE}"
    
    # sun_zenith
    SUN_ZENITH_FILE="${TMP_DIR}/$(basename ${FILE}).sun_zenith"
    hdp_convert "250m 16 days sun zenith angle" "${SUN_ZENITH_FILE}" "${FILE}"
    
    # relative_azimuth
    RELATIVE_AZIMUTH_FILE="${TMP_DIR}/$(basename ${FILE}).relative_azimuth"
    hdp_convert "250m 16 days relative azimuth angle" "${RELATIVE_AZIMUTH_FILE}" "${FILE}"
    
    # day_of_year
    DOY_FILE="${TMP_DIR}/$(basename ${FILE}).doy"
    hdp_convert "250m 16 days composite day of the year" "${DOY_FILE}" "${FILE}"
    
    INTERLEAVED_FILE="${TMP_DIR}/$(basename ${FILE}).scidb"
    echo "2. Juntando layers ..." 
${INTERLEAVER} "$NDVI_FILE" "$EVI_FILE" "$QUALITY_FILE" "$RED_FILE" "$NIR_FILE" "$BLUE_FILE" "$MIR_FILE" "$VIEW_ZENITH_FILE" "$SUN_ZENITH_FILE" "$RELATIVE_AZIMUTH_FILE" "$DOY_FILE" "$INTERLEAVED_FILE"
    END_F_TIME=$(date +%s)
    DIF_F_TIME=$(( ($END_F_TIME - $START_F_TIME) ))
    echo "Arquivo $FILE preparado em $DIF_F_TIME s."

    echo "Removendo arquivos de camadas ..."
    rm "$NDVI_FILE" "$EVI_FILE" "$QUALITY_FILE" "$RED_FILE" "$NIR_FILE" "$BLUE_FILE" "$MIR_FILE" "$VIEW_ZENITH_FILE" "$SUN_ZENITH_FILE" "$RELATIVE_AZIMUTH_FILE" "$DOY_FILE"

    # 3. Carregando no SciDB array 1D
    echo "3. Carregandono SciDB array 1D ..."
    echo "Criando  array 1D ..."
    # 3.1 cria array
    #echo "iquery -a -q \"create array mod13q1_vc_1d_test_1 <ndvi:int16,evi:int16,quality:uint16,red:int16,nir:int16,blue:int16,mir:int16,view_zenith:int16,sun_zenith:int16,relative_azimuth:int16,day_of_year:int16> [i=0:23039999,1000,0];\""
    iquery -a -q "create array mod13q1_vc_1d_test_1 <ndvi:int16,evi:int16,quality:uint16,red:int16,nir:int16,blue:int16,mir:int16,view_zenith:int16,sun_zenith:int16,relative_azimuth:int16,day_of_year:int16> [i=0:23039999,1000,0];"
    
    #  3.2 carrega arquivo
    echo "Carregando arquivo ..."
    #iquery -a -q "load(mod13q1_vc_1d_test,'$INTERLEAVED_FILE',-2,'(int64, int16 null, string null, string)')";
    #echo "iquery -a -q \"set no fetch; load(mod13q1_vc_1d_test_1,'$INTERLEAVED_FILE',-2,'(int16,int16,int16,int16,int16,int16,int16,int16,int16,int16,int16)')\"";
    iquery -a -q "set no fetch; load(mod13q1_vc_1d_test_1,'$INTERLEAVED_FILE',-2,'(int16,int16,int16,int16,int16,int16,int16,int16,int16,int16,int16)')";
    
    # 4. Converte 1D em 3D
    echo "Convertendo 1D em 3D ... "
    #echo "iquery -a -q \"set no fetch; insert(redimension(apply(mod13q1_vc_1d_test_1, row_id, ${V0}+i%4800, col_id, ${H0}+i/4800, time_id, ${TIME}), mod13q1_vc_3d_test_1), mod13q1_vc_3d_test_1);\""
   iquery -a -q "set no fetch; insert(redimension(apply(mod13q1_vc_1d_test_1, row_id, ${V0}+i%4800, col_id, ${H0}+i/4800, time_id, ${TIME}), mod13q1_vc_3d_test_1), mod13q1_vc_3d_test_1);"

    # 4.1 removendo array 1D
    echo "Removendo array 1D ..."
    iquery -a -q "remove(mod13q1_vc_1d_test_1);"

    
done < $INPUT_FILE 

END_TIME=$(date +%s)
DIF_TIME=$(( ($END_TIME - $START_TIME) ))
echo "Finalizada lista de arquivos $INPUT_FILE em $DIF_TIME s."

#iquery -a -q "insert(redimension(apply(mod13q1_vc_1d_test,row_id, 10+i%10, col_id, 20+i/10),mod13q1_vc_test),mod13q1_vc_test);"


