#!/bin/bash

# AIM: Construct weights for bilinear interpolation

# use genbil to construct weights for bilinear interpolation using a 1°deg grid
cdo genbil,1deg.grd, InputFile.nc OutputFile_weights.nc
# You can also use gendis (distance-weighted average) in case of an error in the interpolation weights:
    # Constructing weights for bilinear interpolation using gendis and a "generic" grid at 0.5° resolution
    # cdo gendis,r720x360, InputFile.nc OutputFile_weights.nc