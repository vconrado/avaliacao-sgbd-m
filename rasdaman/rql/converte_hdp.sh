#Fonte https://nsidc.org/data/hdfeos/hdf_to_binary.html

hdp dumpsds -h <inputfilename.hdf> | grep <variable name> 


hdp dumpsds -n <variable name> -o <outputfilename> -b <inputfilename.hdf> 

