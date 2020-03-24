library(doParallel)
library(parallel)

ipath <- "/QRISdata/Q1215/ClimateModels/CMIP6_rclean_regrid_layers/thetao_05deg/ssp126" # Input path
opath <- "/QRISdata/Q1215/ClimateModels/CMIP6_rclean_regrid_vertmean/thetao_05deg/ssp126/" # Output path

dir.nc <- paste(list.dirs(path = ipath, full.names = TRUE, recursive = FALSE))

for(i in 1:length(dir.nc)) {
  
  files.nc <- paste(dir.nc[i], list.files(path = paste(dir.nc[i], sep = "/"), pattern = "*.nc"), sep = "/")
  
  UseCores <- 5
  cl <- makeCluster(UseCores)  
  registerDoParallel(cl)
  
  foreach(j = 1:length(files.nc)) %dopar% {
    system(paste(paste("cdo -P 10 vertmean", sep = ""), files.nc[j], paste0(opath, basename(files.nc[j])), sep = (" ")), intern = TRUE)
  } 
  stopCluster(cl)
}
