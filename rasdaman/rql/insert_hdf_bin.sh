rasql -q 'INSERT INTO mod13q1_basic_all values $1' -f "/data/rasdaman/MOD13Q1.A2007001.h11v09.005.2007021212105.RED.NIR.bin " --mdddomain "[4800:9599,0:4799,0:0]" --mddtype MOD13Q1_basic_arr --user rasadmin --passwd rasadmin


rasql -q 'UPDATE mod13q1_basic_all as c set c[4800:9599,0:4799,0:0] assign $1' -f "/data/rasdaman/MOD13Q1.A2007001.h11v09.0 05.2007021212105.RED.NIR.bin" --mdddomain "[4800:9599,0:4799,0:0]" --mddtype MOD13Q1_basic_arr --user rasadmin --passwd rasadmin
