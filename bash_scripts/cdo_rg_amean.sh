#!/bin/bash

# AIM: Regrid and getting the annual mean of a netCDF file using bilinear interpolation and weights

for m in `seq 1 n` # where n is the number of .nc files
do

# Trick to padd zeros in ksh you would use TYPESET
m=$(printf "%.2d" "$m")
echo MEMBER $m

 # Reggridding a file using remap function to 1°deg of resolution and the bilinear-interpolation weights file previously created
 # In the same code we also estimate the annual mean per file using yearmean function after the pipe operator (-)
    cdo remap,1deg.grd,OutputFile_weights.nc -yearmean ${m}_InputFile.nc ${m}_OutputFile_regridded_annualmean.nc
# If you don't have a standart grid you can use the following example below. Regridding a file using 0.5° weights to 0.5° resolution
    # cdo remap,r720x360,OutputFile_weights.nc -yearmean ${m}_InputFile.nc ${m}_OutputFile_regridded__annualmean.nc
done