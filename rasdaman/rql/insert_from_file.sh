#!/bin/bash

#Fonte: http://tutorial.rasdaman.org/rasdaman-and-ogc-ws-tutorial/
# Cuidado: a query tem q estar entre 'aspas simples' para funcionar o $1
# o tamanho do arquivo deve ser x*y*z*<num_attr>*<attr_size_bytes>

rasql -q 'INSERT INTO mod13q1_nrb values $1' -f "6MB" --mdddomain [0:99,0:99,0:99] --mddtype "MOD3D" --user rasadmin --pass wd rasadmin


