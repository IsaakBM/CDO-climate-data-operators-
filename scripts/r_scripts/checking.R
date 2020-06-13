library(doParallel)
library(parallel)

ipath <- "/QRISdata/Q1215/ClimateModels/CMIP6_rclean_regrid_zmerge/thetao_05deg/ssp585" # Input path
opath <- "/QRISdata/Q1215/ClimateModels/CMIP6_zraster/thetao_05deg/ssp585/" # Output path

dir.nc <- paste(list.dirs(path = ipath, full.names = TRUE, recursive = FALSE))

for(i in 1:length(dir.nc)) {
  
  files.nc <- paste(dir.nc[i], list.files(path = paste(dir.nc[i], sep = "/"), pattern = "*.nc"), sep = "/")
  
  
  for(j in 1:length(files.nc)) {
    system(paste(paste("cdo -sinfov", sep = ""), files.nc[j], sep = (" ")), intern = TRUE)
  } 
  
}
