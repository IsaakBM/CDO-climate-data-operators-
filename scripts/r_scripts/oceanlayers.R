library(doParallel)
library(parallel)

# ipath <- "/Users/bri273/Desktop/CDO/models_regrid/ssp126" # Input path
# opath <- "/Users/bri273/Desktop/CDO/models_regrid_layers/" # Output path

ipath <- "/QRISdata/Q1215/ClimateModels/CMIP6_rclean_regrid/thetao_05deg/ssp585" # Input path
opath <- "/QRISdata/Q1215/ClimateModels/CMIP6_rclean_regrid_layers/thetao_05deg/ssp585/" # Output path

ipath <- "/QRISdata/Q1215/ClimateModels/y_test/ssp585" # Input path
opath <- "/QRISdata/Q1215/ClimateModels/CMIP6_rclean_regrid_layers/thetao_05deg/ssp585/" # Output path


dir.nc <- paste(list.dirs(path = ipath, full.names = TRUE, recursive = FALSE))

for(i in 1:length(dir.nc)) { # number of models inside ssps scenarios
  files.nc <- paste(dir.nc[i], list.files(path = paste(dir.nc[i], sep = "/"), pattern = "*.nc"), sep = "/")
  levels <- as.vector(system(paste("cdo showlevel", files.nc[1]), intern = TRUE))
  
  lev <- unlist(strsplit(levels, split = " "))
  depths <- unique(lev[lev != ""])
  sf <- depths[as.numeric(depths) <= 500]
  ep <- depths[as.numeric(depths) > 500 & as.numeric(depths) <= 20000]
  mp <- depths[as.numeric(depths) > 20000 & as.numeric(depths) <= 100000]
  bap <- depths[as.numeric(depths) > 100000]
  # bp <- depths[as.numeric(depths) > 1000 & as.numeric(depths) <= 4000]
  # abp <- depths[as.numeric(depths) > 4000]
  
  UseCores <- 15
  cl <- makeCluster(UseCores)  
  registerDoParallel(cl)
  
  foreach(j = 1:length(files.nc)) %dopar% {
    system(paste(paste("cdo -L -sellevel,", paste0(sf, collapse = ","), ",", sep = ""), paste("-selname,", "thetao", sep = ""), files.nc[j], paste0(opath, "01-sf_", basename(files.nc[j]))))
    system(paste(paste("cdo -L -sellevel,", paste0(ep, collapse = ","), ",", sep = ""), paste("-selname,", "thetao", sep = ""), files.nc[j], paste0(opath, "02-ep_", basename(files.nc[j]))))
    system(paste(paste("cdo -L -sellevel,", paste0(mp, collapse = ","), ",", sep = ""), paste("-selname,", "thetao", sep = ""), files.nc[j], paste0(opath, "03-mp_", basename(files.nc[j]))))
    system(paste(paste("cdo -L -sellevel,", paste0(bap, collapse = ","), ",", sep = ""), paste("-selname,", "thetao", sep = ""), files.nc[j], paste0(opath, "04-bap_", basename(files.nc[j]))))
    # system(paste(paste("cdo -L -sellevel,", paste0(bp, collapse = ","), ",", sep = ""), paste("-selname,", "thetao", sep = ""), files.nc[j], paste0(opath, "04-bp_", basename(files.nc[j]))))
    # system(paste(paste("cdo -L -sellevel,", paste0(abp, collapse = ","), ",", sep = ""), paste("-selname,", "thetao", sep = ""), files.nc[j], paste0(opath, "05-abp_", basename(files.nc[j]))))
  }
  stopCluster(cl)
}
