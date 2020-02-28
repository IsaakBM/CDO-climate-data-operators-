library(doParallel)
library(parallel)

# ipath <- "/Users/bri273/Desktop/CDO/models_raw/ssp126" # Input path
"/QRISdata/Q1215/ClimateModels/CMIP6_rclean/thetao/ssp245"
ipath <- "/QRISdata/Q1215/ClimateModels/y_test/ssp126"
# opath <- "/Users/bri273/Desktop/CDO/models_regrid/ssp126/" # Output path
opath <- "/QRISdata/Q1215/ClimateModels/y_test/ssp126/"
"/QRISdata/Q1215/ClimateModels/CMIP6_rclean_regrid/"

dir.nc <- paste(list.dirs(path = ipath, full.names = TRUE, recursive = FALSE))

for(i in 1:length(dir.nc)) {
  file.grd <- paste(dir.nc[i], list.files(path = paste(dir.nc[i], sep = "/"), pattern = "*.grd"), sep = "/")
  files.nc <- paste(dir.nc[i], list.files(path = paste(dir.nc[i], sep = "/"), pattern = "*.nc"), sep = "/")
  
  UseCores <- 21
  cl <- makeCluster(UseCores)  
  registerDoParallel(cl)
  
  foreach(j = 1:length(files.nc)) %dopar% {
    system(paste(paste("cdo -L remapbil,", file.grd, ",", sep = ""), files.nc[j], paste0(opath, basename(files.nc[j])), sep = (" ")))
  } 
  stopCluster(cl)
}
