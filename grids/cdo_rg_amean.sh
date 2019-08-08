#!/bin/bash


for m in `seq 1 9`
do

# Trick to padd zeros in ksh you would use TYPESET
m=$(printf "%.2d" "$m")
echo MEMBER $m

 # using pipe operator
cdo remapbil,1deg.grd, -yearmean thetao_${m}_Omon_CanESM5_ssp126_r1i1p1f1_gn.nc thetao_${m}_rgam_Omon_CanESM5_ssp126_r1i1p1f1_gn.nc

done
