library(doParallel)
library(parallel)

ipath <- "/QRISdata/Q1215/ClimateModels/CMIP6_rclean/thetao/ssp126"
opath <- "/QRISdata/Q1215/ClimateModels/CMIP6_rclean_regrid/thetao_05deg/ssp126/"

#ipath <- "/QRISdata/Q1215/ClimateModels/CMIP6_rclean/tob/ssp126"
#opath <- "/QRISdata/Q1215/ClimateModels/CMIP6_rclean_regrid/tob_05deg/ssp126/"

dir.nc <- paste(list.dirs(path = ipath, full.names = TRUE, recursive = FALSE))

for(i in 1:length(dir.nc)) {
  file.grd <- paste(dir.nc[i], list.files(path = paste(dir.nc[i], sep = "/"), pattern = "*.grd"), sep = "/")
  files.nc <- paste(dir.nc[i], list.files(path = paste(dir.nc[i], sep = "/"), pattern = "*.nc"), sep = "/")
  
  UseCores <- 5
  cl <- makeCluster(UseCores)  
  registerDoParallel(cl)
  
  foreach(j = 1:length(files.nc)) %dopar% {
    # system(paste(paste("cdo -L remapbil,", file.grd, ",", sep = ""), files.nc[j], paste0(opath, basename(files.nc[j])), sep = (" ")))
    # system(paste(paste("cdo -L remapbil,", file.grd, ",", sep = ""), paste("-selname","thetao", sep = ","), files.nc[j], paste0(opath, basename(files.nc[j])), sep = (" ")))
    # system(paste(paste("cdo -f nc -remapbil,", file.grd, ",", sep = ""), paste("-selname","thetao", sep = ","), files.nc[j], paste0(opath, basename(files.nc[j])), sep = (" ")))
     system(paste(paste("cdo -P 10 -remapbil,", file.grd, ",", sep = ""), paste("-selname","thetao", sep = ","), files.nc[j], paste0(opath, basename(files.nc[j])), sep = (" ")))
    # system(paste(paste("cdo -P 10 -remapbil,", file.grd, ",", sep = ""), paste("-selname","tob", sep = ","), files.nc[j], paste0(opath, basename(files.nc[j])), sep = (" ")))
  } 
  stopCluster(cl)
}

# module load R/3.5.0-intel
# cdo remapbil,1deg.grd, -selname,thetao [paste("-selname","thetao", sep = ",")]
