# This code was written by Isaac Brito-Morales (i.britomorales@uq.edu.au)
# Please do not distribute this code without permission.
# NO GUARANTEES THAT CODE IS CORRECT
# Caveat Emptor!

# Function's arguments
# ipath: directory where the netCDF files are located
# opath: directory to allocate the new regrided netCDF files
# resolution = resolution for the regrid process

merge_files <- function(ipath, opath1) {

  library(doParallel)
  library(parallel)
  library(stringr)
  
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
    final_nc <- lapply(dir_nc, function(x){f1 <- tail(x, n = 1)})
    files.nc <- unlist(final_nc)
 
####################################################################################
####### Filtering by layers and generating new netCDF files with outputs
#################################################################################### 
  # Filtering (not dplyr!) by ocean layers
    sf <- files.nc[str_detect(string = basename(files.nc), pattern = "01-sf*") == TRUE]
    ep <- files.nc[str_detect(string = basename(files.nc), pattern = "02-ep*") == TRUE]
    mp <- files.nc[str_detect(string = basename(files.nc), pattern = "03-mp*") == TRUE]
    bap <- files.nc[str_detect(string = basename(files.nc), pattern = "04-bap*") == TRUE]
  # Defining how many models are per ocean layer [this looks really ugly so try to find a better way later]
    model_list_sf <- lapply(sf, function(x) {d1 <- unlist(strsplit(x = basename(x), split = "_"))[4]})
    model_list_ep <- lapply(ep, function(x) {d1 <- unlist(strsplit(x = basename(x), split = "_"))[4]})
    model_list_mp <- lapply(bap, function(x) {d1 <- unlist(strsplit(x = basename(x), split = "_"))[4]})
    model_list_bap <- lapply(bap, function(x) {d1 <- unlist(strsplit(x = basename(x), split = "_"))[4]})
    models <- unique(unlist(c(model_list_sf, model_list_ep, model_list_mp, model_list_bap))) # how many models are?
  # Parallel looop
    cl <- makeCluster(10)
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

merge_files(ipath = "/gpfs1/scratch/30days/uqibrito/Project05c_Anne/ClimateModels/models_regrid_vertmean/",
            opath1 = "/gpfs1/scratch/30days/uqibrito/Project05c_Anne/ClimateModels/models_regrid_zmerge/")
