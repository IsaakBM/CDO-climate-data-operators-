# This code was written by Isaac Brito-Morales (i.britomorales@uq.edu.au)
# Please do not distribute this code without permission.
# NO GUARANTEES THAT CODE IS CORRECT
# Caveat Emptor!

# Function's arguments
# ipath: directory where the netCDF files are located
# opath: directory to allocate the new regrided netCDF files
# resolution = resolution for the regrid process

regrid <- function(ipath, opath, resolution) {

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
  # Resolution? You can add more if you want (but do not push too much!)
    if(resolution == "1") {
      grd <- "r360x180"
    } else if(resolution == "0.5") {
      grd <- "r720x360"
    } else if(resolution == "0.25") {
      grd <- "r1440x720"
    }
    
  # Parallel looop
    UseCores <- 10 # we can change this number in the HPC or your machine (mine is crap)
    cl <- makeCluster(UseCores)  
    registerDoParallel(cl)
    foreach(j = 1:length(files.nc), .packages = c("stringr")) %dopar% {
      # Trying to auto the name for every model
        var_obj <- system(paste("cdo -showname", files.nc[j]), intern = TRUE)
        var_all <- str_replace_all(string = var_obj, pattern = " ", replacement = "_")
        var <- tail(unlist(strsplit(var_all, split = "_")), n = 1) # i believe that the name of the variable is always at the end
      # Running CDO regrid
        system(paste(paste("cdo -remapbil,", grd, ",", sep = ""), 
                     paste("-selname",var, sep = ","), files.nc[j], 
                     paste0(opath, basename(files.nc[j])), sep = (" "))) # -P 2
    }
    stopCluster(cl)
}

regrid(ipath = "/Users/bri273/Desktop/CDO/models_raw/ssp126/",
       opath = "/Users/bri273/Desktop/CDO/models_regrid/",
       resolution = "1")
