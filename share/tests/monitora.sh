#!/bin/bash
#
# Script que coleta o horário de inicio e término de um teste
# Created: 2017-02-10 
# Updated: 2017-02-10
#
# - Recebe como parâmetro de entrada o nome do script a ser executado
# - Salva um arquivo CSV com o horário de inicio e fim do teste
#

# Verifica se recebeu argumento

if [ "$#" -lt 2 ]; then
    echo "Illegal number of parameters"
    exit
fi

OUTPUT_FILE=$1
SCRIPT=$(realpath $2)

if [ -f "$OUTPUT_FILE" ]; then
        echo "Output file $OUTPUT_FILE already exists!";
        exit;
fi

# Verifica se o script existe
if [ ! -x "$SCRIPT" ]; then
        echo "File $SCRIPT is not executable or found"
        exit
fi

START_TIME=$(date +%s)
$SCRIPT ${@:3}
END_TIME=$(date +%s)

DIF_TIME=`expr $END_TIME - $START_TIME`

echo "${START_TIME}, ${END_TIME}, ${DIF_TIME}" > $OUTPUT_FILE
