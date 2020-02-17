library(doParallel)
library(parallel)

ipath <- "/Users/bri273/Desktop/CDO/models_regrid_layers" # Input path
opath <- "/Users/bri273/Desktop/CDO/models_regrid_vertmean/" # Output path

dir.nc <- paste(list.dirs(path = ipath, full.names = TRUE, recursive = FALSE))

for(i in 1:length(dir.nc)) {
  
  files.nc <- paste(dir.nc[i], list.files(path = paste(dir.nc[i], sep = "/"), pattern = "*.nc"), sep = "/")
  
  UseCores <- detectCores() - 1
  cl <- makeCluster(UseCores)  
  registerDoParallel(cl)
  
  foreach(j = 1:length(files.nc)) %dopar% {
    system(paste(paste("cdo -L vertmean", sep = ""), files.nc[j], paste0(opath, basename(files.nc[j])), sep = (" ")), intern = TRUE)
  } 
  stopCluster(cl)
}