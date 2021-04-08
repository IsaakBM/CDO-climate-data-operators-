# This code was written by Isaac Brito-Morales (i.britomorales@uq.edu.au)
# Please do not distribute this code without permission.
# NO GUARANTEES THAT CODE IS CORRECT
# Caveat Emptor!

# Function's arguments
# ipath: directory where the netCDF files are located
# opath: directory to allocate the new regrided netCDF files
# resolution = resolution for the regrid process

olayer <- function(ipath, opath) {

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
####### Starting the regrid process
#################################################################################### 
  # Parallel looop
    UseCores <- 3 # we can change this number in the HPC or your machine (mine is crap)
    cl <- makeCluster(UseCores)  
    registerDoParallel(cl)
    foreach(j = 1:length(files.nc), .packages = c("stringr")) %dopar% {
      # Trying to auto the name for every model
        var_obj <- system(paste("cdo -showname", files.nc[j]), intern = TRUE)
        var_all <- str_replace_all(string = var_obj, pattern = " ", replacement = "_")
        var <- tail(unlist(strsplit(var_all, split = "_")), n = 1) # i believe that the name of the variable is always at the end
      # Defining depths
        levels <- as.vector(system(paste("cdo showlevel", files.nc[j]), intern = TRUE))
        lev <- unlist(strsplit(levels, split = " "))
        depths <- unique(lev[lev != ""])
        sf <- depths[as.numeric(depths) <= 5]
        ep <- depths[as.numeric(depths) >= 0 & as.numeric(depths) <= 200]
        mp <- depths[as.numeric(depths) > 200 & as.numeric(depths) <= 1000]
        bap <- depths[as.numeric(depths) > 1000]
      # Running CDO regrid
        # Surface
          system(paste(paste("cdo -L -sellevel,", 
                             paste0(sf, collapse = ","), ",", sep = ""), 
                       paste("-selname,", var, sep = ""), files.nc[j], 
                       paste0(opath, "01-sf_", basename(files.nc[j]))))
        # Epipelagic
          system(paste(paste("cdo -L -sellevel,", 
                             paste0(ep, collapse = ","), ",", sep = ""), 
                       paste("-selname,", var, sep = ""), files.nc[j], 
                       paste0(opath, "02-ep_", basename(files.nc[j]))))
        # Mesopelagic
          system(paste(paste("cdo -L -sellevel,", 
                             paste0(mp, collapse = ","), ",", sep = ""), 
                       paste("-selname,", var, sep = ""), files.nc[j], 
                       paste0(opath, "03-mp_", basename(files.nc[j]))))
        # Bathypelagic
          system(paste(paste("cdo -L -sellevel,", 
                             paste0(bap, collapse = ","), ",", sep = ""), 
                       paste("-selname,", var, sep = ""), files.nc[j], 
                       paste0(opath, "04-bap_", basename(files.nc[j]))))
    }
    stopCluster(cl)
}

regrid(ipath = "/Users/bri273/Desktop/CDO/models_regrid/ssp126/ACCESS-CM2/",
       opath = "/Users/bri273/Desktop/CDO/models_regrid_layers/")
