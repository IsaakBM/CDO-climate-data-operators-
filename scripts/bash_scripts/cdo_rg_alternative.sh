#!/bin/bash

# AIM: Regrid and getting the annual mean of a netCDF file using bilinear interpolation BUT NO WEIGHTS

for m in `seq 1 n` # where n is the number of .nc files
do

# Trick to padd zeros in ksh you would use TYPESET
m=$(printf "%.2d" "$m")
echo MEMBER $m

# Reggridding a file using remapbil function to 1°deg of resolution without bilinear-interpolation weights
# In the same code we also estimate the annual mean per file using yearmean function after the pipe operator (-)
    cdo remapbil,1deg.grd, -yearmean ${m}_InputFile.nc ${m}_OutputFile_regridded_annualmean.nc

done