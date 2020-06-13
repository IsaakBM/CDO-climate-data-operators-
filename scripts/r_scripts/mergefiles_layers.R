library(doParallel)
library(parallel)

ipath <- "/QRISdata/Q1215/ClimateModels/CMIP6_rclean_regrid_vertmean/thetao_05deg/ssp245" # Input path
opath <- "/QRISdata/Q1215/ClimateModels/CMIP6_rclean_regrid_zmerge/thetao_05deg/ssp245/" # Output path
 
# ipath <- "/Users/bri273/Desktop/CDO/models_regrid_zmerge/ssp126" # Input path
# opath <- "/Users/bri273/Desktop/CDO/models_regrid_zmerge/"

dir.nc <- paste(list.dirs(path = ipath, full.names = TRUE, recursive = FALSE))

# UseCores <- 5
# cl <- makeCluster(UseCores)  
# registerDoParallel(cl)

for(i in 1:length(dir.nc)) {
  
  files.sf <- paste(dir.nc[i], list.files(path = paste(dir.nc[i], sep = "/"), pattern = "01-sf*"), sep = "/")
  files.ep <- paste(dir.nc[i], list.files(path = paste(dir.nc[i], sep = "/"), pattern = "02-ep*"), sep = "/")
  files.mp <- paste(dir.nc[i], list.files(path = paste(dir.nc[i], sep = "/"), pattern = "03-mp*"), sep = "/")
  files.bap <- paste(dir.nc[i], list.files(path = paste(dir.nc[i], sep = "/"), pattern = "04-bap*"), sep = "/")
  
  sf <- "01-sf"
  ep <- "02-ep"
  mp <- "03-mp"
  bap <- "04-bap"
  
  system(paste(paste("cdo -L mergetime", paste0(dir.nc[i], "/", sf, "*.nc", collapse = " "), sep = " "), paste0(opath, paste(unlist(strsplit(basename(files.sf[1]), "_"))[c(1:6)], collapse = "_"), ".nc"), sep = (" ")), intern = TRUE)
  system(paste(paste("cdo -L mergetime", paste0(dir.nc[i], "/", ep, "*.nc", collapse = " "), sep = " "), paste0(opath, paste(unlist(strsplit(basename(files.ep[1]), "_"))[c(1:6)], collapse = "_"), ".nc"), sep = (" ")), intern = TRUE)
  system(paste(paste("cdo -L mergetime", paste0(dir.nc[i], "/", mp, "*.nc", collapse = " "), sep = " "), paste0(opath, paste(unlist(strsplit(basename(files.mp[1]), "_"))[c(1:6)], collapse = "_"), ".nc"), sep = (" ")), intern = TRUE)
  system(paste(paste("cdo -L mergetime", paste0(dir.nc[i], "/", bap, "*.nc", collapse = " "), sep = " "), paste0(opath, paste(unlist(strsplit(basename(files.bap[1]), "_"))[c(1:6)], collapse = "_"), ".nc"), sep = (" ")), intern = TRUE)

}
# stopCluster(cl)

