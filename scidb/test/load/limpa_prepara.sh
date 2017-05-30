#!/bin/bash


iquery -a -q "remove(mod13q1_vc_1d_test_1);"

iquery -a -q "remove(mod13q1_vc_3d_test_1);"

iquery -a -q "create array mod13q1_vc_3d_test_1 <ndvi:int16,evi:int16,quality:uint16,red:int16,nir:int16,blue:int16,mir:int16,view_zenith:int16,sun_zenith:int16,relative_azimuth:int16,day_of_year:int16> [col_id=0:172799,40,0,row_id=0:86399,40,0,time_id=0:511,512,0];"
