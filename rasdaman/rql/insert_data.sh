#!/bin/bash
#rasql  -q "insert into mod13q1_nrb values marray x in [0:10, 0:12, 0:14] values {0us, 1us, 2us}" --out string --user rasadmin --passwd rasadmin

# Default values: https://lpdaac.usgs.gov/dataset_discovery/modis/modis_products_table/mod13q1_v006
rasql -q "insert into mod13q1_all values marray it in [0:9599, 0:4799, 0:0] values {-3000s, -3000s, 65536s, -1000s, -1000s, -1000s, -1000s, -10000s, -10000s, -4000s, -1s, 255o}" --user rasadmin --passwd rasadmin
