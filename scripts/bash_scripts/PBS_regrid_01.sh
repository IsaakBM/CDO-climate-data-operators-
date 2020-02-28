#!/bin/bash
#PBS -A qris-uq
#PBS -l walltime=1:00:00
#PBS -l select=6:ncpus=4:mem=80GB

cd $PBS_O_WORKDIR

module load cdo
module load ncview
module load geos
module load gdal
module load R/3.5.0

export INCLUDE=$INCLUDE:/opt/netcdf/4.3.2/gnu/openmpi_ib/lib

R CMD BATCH "/QRISdata/Q1215/ClimateModels/y_test/regrid01.R"
