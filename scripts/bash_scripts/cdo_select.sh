#!/bin/bash

# AIM: Select just the variable that you want for the regridding process

for m in `seq 1 n` # where n is the number of .nc files
do

# Trick to padd zeros in ksh you would use TYPESET
m=$(printf "%.2d" "$m")
echo MEMBER $m

# Selecting just thetao. thetao usually come in a 4D array format. However, some .nc files have more than just one variable 
# and in cases 3D format. This will cause an error in cdo. To avoid this issue, we use select to filter and creating a new
# .nc file(s) that can we easly regrid.
    cdo select,name=thetao ${m}_InputFile.nc ${m}_OutputFile_thetao.nc

done