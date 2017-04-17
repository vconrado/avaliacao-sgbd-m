#!/bin/bash
# Baseado em http://www.rasdaman.org/wiki/PartialUpdates para inserir tiffs
rasql -q 'UPDATE mod13q1_all as c set c[0:4799, 0:4799,0] assing inv_hdf($1)' --file /disks/d14/2015/MOD13Q1.A2015001.h09v07.005.2015027160143.hdf --mdddomain [0:4799,0:4799,0:0] --mddtype mod13q1_str --user rasadmin --passwd rasadmin
