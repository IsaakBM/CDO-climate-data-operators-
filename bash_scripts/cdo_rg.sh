#!/bin/bash

# AIM: Regrid a netCDF file using bilinear interpolation and weights

for m in `seq 1 n` # where n is the number of .nc files
do

# Trick to padd zeros in ksh you would use TYPESET
m=$(printf "%.2d" "$m")
echo MEMBER $m

 # Reggridding a file using remap function to 1°deg of resolution and the bilinear-interpolation weights file previously created
    cdo remap,1deg.grd,OutputFile_weights.nc ${m}_InputFile.nc ${m}_OutputFile_regridded.nc
# If you don't have a standart grid you can use the following example below. Regridding a file using 0.5° weights to 0.5° resolution
    # cdo remap,r720x360,OutputFile_weights.nc ${m}_InputFile.nc ${m}_OutputFile_regridded.nc
done