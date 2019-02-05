#!/bin/bash


for m in `seq 1 19`
do

# Trick to padd zeros in ksh you would use TYPESET
m=$(printf "%.2d" "$m")
echo MEMBER $m

cdo yearmin thetao_${m}_rg_Omon_ACCESS1-3_rcp45_r1i1p1.nc thetao_${m}_amin_Omon_ACCESS1-3_rcp45_r1i1p1.nc

done
