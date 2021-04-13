library(doParallel)
library(parallel)

ipath <- "/QRISdata/Q1215/ClimateModels/CMIP6_rclean_regrid_yearmean/thetao_05deg/ssp585" # Input path
opath <- "/QRISdata/Q1215/ClimateModels/CMIP6_rclean_regrid_yearmean/thetao_05deg/ssp585/" # Output path

dir.nc <- paste(list.dirs(path = ipath, full.names = TRUE, recursive = FALSE))

for(i in 1:length(dir.nc)) {
  # Surface files
  files.sf <- paste(dir.nc[i], list.files(path = paste(dir.nc[i], sep = "/"), pattern = "*-sf*"), sep = "/")
  # split files' name
  nm_sf01 <- unlist(strsplit(min(basename(files.sf)), split = "_")) # the first file
  nm_sf02 <- unlist(strsplit(max(basename(files.sf)), split = "_")) # the last file
  # Create a new name with the CORRECT time frame
  name.sf <- paste(nm_sf01[1], nm_sf01[2], nm_sf01[3], nm_sf01[4], nm_sf01[5], nm_sf01[6], paste(unlist(strsplit(nm_sf01[8], split = "-"))[1], unlist(strsplit(nm_sf02[8], split = "-"))[2], sep = "-"), sep = "_")
  system(paste(paste("cdo -L mergetime", sep = ""), paste(dir.nc[i], "01-*.nc", sep = "/"), paste0(opath, name.sf), sep = (" ")), intern = TRUE)
}

for(j in 1:length(dir.nc)) {
  # Epipelagic files
  files.ep <- paste(dir.nc[j], list.files(path = paste(dir.nc[j], sep = "/"), pattern = "*-ep*"), sep = "/")
  # split files' name
  nm_ep01 <- unlist(strsplit(min(basename(files.ep)), split = "_")) # the first file
  nm_ep02 <- unlist(strsplit(max(basename(files.ep)), split = "_")) # the last file
  # Create a new name with the CORRECT time frame
  name.ep <- paste(nm_ep01[1], nm_ep01[2], nm_ep01[3], nm_ep01[4], nm_ep01[5], nm_ep01[6], paste(unlist(strsplit(nm_ep01[8], split = "-"))[1], unlist(strsplit(nm_ep02[8], split = "-"))[2], sep = "-"), sep = "_")
  system(paste(paste("cdo -L mergetime", sep = ""), paste(dir.nc[j], "02-*.nc", sep = "/"), paste0(opath, name.ep), sep = (" ")), intern = TRUE)
}

for(k in 1:length(dir.nc)) { 
  # Mesopelagic files
  files.mp <- paste(dir.nc[k], list.files(path = paste(dir.nc[k], sep = "/"), pattern = "*-mp*"), sep = "/")
  # split files' name
  nm_mp01 <- unlist(strsplit(min(basename(files.mp)), split = "_")) # the first file
  nm_mp02 <- unlist(strsplit(max(basename(files.mp)), split = "_")) # the last file
  # Create a new name with the CORRECT time frame
  name.mp <- paste(nm_mp01[1], nm_mp01[2], nm_mp01[3], nm_mp01[4], nm_mp01[5], nm_mp01[6], paste(unlist(strsplit(nm_mp01[8], split = "-"))[1], unlist(strsplit(nm_mp02[8], split = "-"))[2], sep = "-"), sep = "_")
  system(paste(paste("cdo -L mergetime", sep = ""), paste(dir.nc[k], "03-*.nc", sep = "/"), paste0(opath, name.mp), sep = (" ")), intern = TRUE)
}

for(l in 1:length(dir.nc)) {
  # Bathypelagic files
  files.bp <- paste(dir.nc[l], list.files(path = paste(dir.nc[l], sep = "/"), pattern = "*-bp*"), sep = "/")
  # split files' name
  nm_bp01 <- unlist(strsplit(min(basename(files.bp)), split = "_")) # the first file
  nm_bp02 <- unlist(strsplit(max(basename(files.bp)), split = "_")) # the last file
  # Create a new name with the CORRECT time frame
  name.bp <- paste(nm_bp01[1], nm_bp01[2], nm_bp01[3], nm_bp01[4], nm_bp01[5], nm_bp01[6], paste(unlist(strsplit(nm_bp01[8], split = "-"))[1], unlist(strsplit(nm_bp02[8], split = "-"))[2], sep = "-"), sep = "_")
  system(paste(paste("cdo -L mergetime", sep = ""), paste(dir.nc[l], "04-*.nc", sep = "/"), paste0(opath, name.bp), sep = (" ")), intern = TRUE)
}