#!/bin/bash
#
# Cria os arquivos com a lista de de arquivos HDF que existem nos discos selecionados
# Gera seguintes arquivos dentro da pasta $DIR
#	- hdf.files.doys: com a lista de dias únidos dos arquivos
#	- hdf.files.hv: lista com as celulas únidas ocupadas pelos arquivos
#	- hdf.<dir>·partial: lista de arquivos hdf do diretório <dir>
#	- hdf.files: lista consolidada de todos os arquivos hdf (todos os <dir>'s)


DIR=./data

find /disks/d14 -name "*.hdf" | sort > $DIR/hdf.files.d14.partial
find /disks/d15 -name "*.hdf" | sort > $DIR/hdf.files.d15.partial

cat $DIR/*.partial | sort | uniq > $DIR/hdf.files


cat $DIR/hdf.files | cut -d '.' -f 2 | sort | uniq > $DIR/hdf.files.doys
cat $DIR/hdf.files | cut -d '.' -f 3 | sort | uniq > $DIR/hdf.files.hv

