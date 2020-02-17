#!/bin/bash
#PBS -A qris-uq
#PBS -l walltime=2:00:00
#PBS -l select=6:ncpus=4:mem=80GB
        #+6:ncpus=20:mem=500GB

cd $PBS_O_WORKDIR

module load parallel
module load cdo
module load R/3.5.0

R CMD BATCH "/QRISdata/Q1216/BritoMorales/zztest/regrid/regrid01.R"
