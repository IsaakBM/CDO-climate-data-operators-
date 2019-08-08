#!/bin/bash


for m in `seq 1 2`
do

# Trick to padd zeros in ksh you would use TYPESET
m=$(printf "%.2d" "$m")
echo MEMBER $m

 # using pipe operator
cdo select,name=thetao thetao_${m}_Omon_MIROC6_ssp126_r1i1p1f1_gn.nc thetao_${m}_rgam_Omon_MIROC6_ssp126_r1i1p1f1_gn.nc

done
