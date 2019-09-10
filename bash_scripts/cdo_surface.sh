#!/bin/bash

# AIM: Select just one level in a 4D array .nc file

for m in `seq 1 n` # where n is the number of .nc files
do

# Trick to padd zeros in ksh you would use TYPESET
m=$(printf "%.2d" "$m")
echo MEMBER $m

# Selecting just surface. You can explore more levels using: cdo sinfo InputFile.nc
    cdo -sellevel,5 -selname,thetao ${m}_InputFile.nc ${m}_OutputFile_thetao_surface.nc

done