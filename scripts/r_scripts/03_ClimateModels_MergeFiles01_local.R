# This code was written by Isaac Brito-Morales (i.britomorales@uq.edu.au)
# Please do not distribute this code without permission.
# NO GUARANTEES THAT CODE IS CORRECT
# Caveat Emptor!

# Function's arguments
# ipath: directory where the netCDF files are located
# opath: directory to allocate the new regrided netCDF files
# resolution = resolution for the regrid process

merge_files <- function(ipath, opath1) {

####################################################################################
####### Defining the main packages (tryining to auto this)
####################################################################################
  # List of pacakges that we will be used
    list.of.packages <- c("doParallel", "parallel", "stringr", "data.table")
  # If is not installed, install the pacakge
    new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
    if(length(new.packages)) install.packages(new.packages)
  # Load packages
    lapply(list.of.packages, require, character.only = TRUE)
  
####################################################################################
####### Getting the path and directories for the files
####################################################################################
  # Establish the find bash command
    line1 <- paste(noquote("find"), noquote(ipath), "-type", "f", "-name", noquote("*.nc"), "-exec", "ls", "-l", "{}")
    line2 <- paste0("\\", ";")
    line3 <- paste(line1, line2)
  # Getting a list of directories for every netCDF file
    dir_files <- system(line3, intern = TRUE)
    dir_nc <- strsplit(x = dir_files, split = " ")
    nc_list <- lapply(dir_nc, function(x){f1 <- tail(x, n = 1)})
  # Cleaning the directories to get a final vector of directories
    final_nc <- lapply(nc_list, function(x) {
      c1 <- str_split(unlist(x), pattern = "//")
      c2 <- paste(c1[[1]][1], c1[[1]][2], sep = "/")})
    files.nc <- unlist(final_nc)
 
####################################################################################
####### Filtering by layers and generating new netCDF files with outputs
#################################################################################### 
  # Filtering (not dplyr!) by ocean layers
    sf <- files.nc[str_detect(string = basename(files.nc), pattern = "01-sf*") == TRUE]
    ep <- files.nc[str_detect(string = basename(files.nc), pattern = "02-ep*") == TRUE]
    mp <- files.nc[str_detect(string = basename(files.nc), pattern = "03-mp*") == TRUE]
    bap <- files.nc[str_detect(string = basename(files.nc), pattern = "04-bap*") == TRUE]
  # Defining how many models are per ocean layer [this looks really ugly so try to find a better way later Isaac]
    model_list_sf <- lapply(sf, function(x) {d1 <- unlist(strsplit(x = basename(x), split = "_"))[4]})
    model_list_ep <- lapply(ep, function(x) {d1 <- unlist(strsplit(x = basename(x), split = "_"))[4]})
    model_list_mp <- lapply(bap, function(x) {d1 <- unlist(strsplit(x = basename(x), split = "_"))[4]})
    model_list_bap <- lapply(bap, function(x) {d1 <- unlist(strsplit(x = basename(x), split = "_"))[4]})
    models <- unique(unlist(c(model_list_sf, model_list_ep, model_list_mp, model_list_bap))) # how many models are?
  # Parallel looop
    cl <- makeCluster(3)
    registerDoParallel(cl)
    foreach(i = 1:length(models), .packages = c("stringr")) %dopar% {
      f1 <- ep[str_detect(string = basename(sf), pattern = models[i]) == TRUE]
      system(paste(paste("cdo -L mergetime", paste0(f1, collapse = " "), sep = " "), 
                   paste0(opath1, paste(unlist(strsplit(basename(f1[1]), "_"))[c(1:7)], collapse = "_"), ".nc"), sep = (" ")))
      f2 <- ep[str_detect(string = basename(ep), pattern = models[i]) == TRUE]
      system(paste(paste("cdo -L mergetime", paste0(f2, collapse = " "), sep = " "), 
                   paste0(opath1, paste(unlist(strsplit(basename(f2[1]), "_"))[c(1:7)], collapse = "_"), ".nc"), sep = (" ")))
      f3 <- mp[str_detect(string = basename(mp), pattern = models[i]) == TRUE]
      system(paste(paste("cdo -L mergetime", paste0(f3, collapse = " "), sep = " "), 
                   paste0(opath1, paste(unlist(strsplit(basename(f3[1]), "_"))[c(1:7)], collapse = "_"), ".nc"), sep = (" ")))
      f4 <- bap[str_detect(string = basename(bap), pattern = models[i]) == TRUE]
      system(paste(paste("cdo -L mergetime", paste0(f4, collapse = " "), sep = " "), 
                   paste0(opath1, paste(unlist(strsplit(basename(f4[1]), "_"))[c(1:7)], collapse = "_"), ".nc"), sep = (" ")))
    }
    stopCluster(cl)
}

merge_files(ipath = "/Users/bri273/Desktop/CDO/models_regrid_vertmean/",
            opath1 = "/Users/bri273/Desktop/CDO/models_regrid_zmerge/")
