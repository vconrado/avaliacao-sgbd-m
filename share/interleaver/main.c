#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

void usage(char *name);

int main(int argc, char* argv[]){
	// MODIS Files Constants

	// MOD13Q1 Bands: ndvi,evi,quality,red,nir,blue,mir,view_zenith,sun_zenith,relative_azimuth,day_of_year, reliability
	int bytes[] ={2,2,2,2,2,2,2,2,2,2,2,1}; // number of bytes per band of MOD13Q1 (1pixel = 23bytes)
	int n_files = 12;			// number of files (=bands)
	int8_t data[23];			// var to read data
	int domain_dimension=4800*4800;

	// General vars	
	int i,j;
	FILE *in_files[12];
	FILE *out_file;
	int seek;

	if(argc != (n_files+2)) {
		usage(argv[0]);
		return 1;
	}
	
	// try to open output file
	out_file = fopen(argv[13],"wb");
	if(out_file == NULL){
		fprintf(stderr,"Was not possible to create output file '%s'\n", argv[13]);
		return 2;
	}
	// try to open all input 12 files
	for(i=0;i<n_files; ++i){
		in_files[i] = fopen(argv[i+1], "rb");
		if(in_files[i] == NULL){
			fprintf(stderr,"Was not possible to open input file '%s'\n", argv[i+1]);
			for(j=i-1; j>=0; --j){
				fprintf(stderr,"Closing file #%d\n", j);
				fclose(in_files[j]);
			}
			return 3;
		}
	}

	// read 12 input files and write on output file
	// TODO: Read all 12 files to memory and then write to output file (check memory usage first)
	for(i=0; i<domain_dimension; ++i){
		seek = 0;
		for(j=0; j<n_files; ++j){
			if(fread(&data[seek], sizeof(int8_t),bytes[j], in_files[j]) != bytes[j]){
				fprintf(stderr,"Error while reading file %s. ", argv[j+1]);
			}
			seek+=bytes[j];
		}
		fwrite(&data[0], sizeof(int8_t), 23, out_file);
	}
		
	
	fclose(out_file);
	for(i=0; i<n_files; ++i){
		fclose(in_files[i]);
	}
	
	return 0;
}

void usage(char *name){
	fprintf(stderr,"Usage: %s ndvi_file evi_file quality_file red_file nir_file blue_file mir_file view_zenith_file sun_zenith_file relative_azimuth_file day_of_year_file reliability_file\n", name);
}
