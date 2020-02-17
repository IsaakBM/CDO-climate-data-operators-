#!/bin/bash

# AIM: Getting the annual mean of a netCDF file

for m in `seq 1 n` # where n is the number of .nc files
do

# Trick to padd zeros in ksh you would use TYPESET
m=$(printf "%.2d" "$m")
echo MEMBER $m

cdo yearmean ${m}_InputFile.nc ${m}_OutputFile.nc # you can replace this by yearmin yearmax if you want other estimations

done