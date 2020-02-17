library(doParallel)
library(parallel)

ipath <- "/QRISdata/Q1216/BritoMorales/zztest/regrid" # Input path
opath <- "/QRISdata/Q1216/BritoMorales/zztest/regrid/" # Output path

dir.nc <- paste(list.dirs(path = ipath, full.names = TRUE, recursive = FALSE))

for(i in 1:length(dir.nc)) {
  file.grd <- paste(dir.nc[i], list.files(path = paste(dir.nc[i], sep = "/"), pattern = "*.grd"), sep = "/")
  files.nc <- paste(dir.nc[i], list.files(path = paste(dir.nc[i], sep = "/"), pattern = "*.nc"), sep = "/")
  UseCores <- 21
  cl <- makeCluster(UseCores)  
  registerDoParallel(cl)
  
  foreach(j = 1:length(files.nc)) %dopar% {
    system(paste(paste("cdo remapbil,", file.grd, ",", sep = ""), files.nc[j], paste0(opath, basename(files.nc[j])), sep = (" ")))
  } 
  stopCluster(cl)
}