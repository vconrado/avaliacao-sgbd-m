#!/bin/bash
# Baseado em http://www.rasdaman.org/wiki/PartialUpdates para inserir tiffs
rasql -q "UPDATE mod13q1_all as c set c[4800:9599, 4800:9599,0] assing inv_hdf($1)" --file /data/raw/MOD13Q1.A2015001.h09v08.005.2015027154848.hdf --user rasadmin --passwd rasadmin
