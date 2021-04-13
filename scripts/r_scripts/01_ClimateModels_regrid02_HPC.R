# This code was written by Isaac Brito-Morales (i.britomorales@uq.edu.au)
# Please do not distribute this code without permission.
# NO GUARANTEES THAT CODE IS CORRECT
# Caveat Emptor!

# Function's arguments
# ipath: directory where the netCDF files are located
# opath: directory to allocate the new regrided netCDF files
# resolution = resolution for the regrid process

regrid <- function(ipath, opath, resolution) {
  
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
    cl <- makeCluster(10)
    registerDoParallel(cl)
    foreach(j = 1:length(files.nc), .packages = c("stringr")) %dopar% {
      # Trying to auto the name for every model
        var_obj <- system(paste("cdo -showname", files.nc[j]), intern = TRUE)
        var_all <- str_replace_all(string = var_obj, pattern = " ", replacement = "_")
        var <- tail(unlist(strsplit(var_all, split = "_")), n = 1) # i believe that the name of the variable is always at the end
      # Running CDO regrid
        system(paste(paste("cdo -P 2 -remapbil,", grd, ",", sep = ""), 
                     paste("-selname",var, sep = ","), files.nc[j], 
                     paste0(opath, basename(files.nc[j])), sep = (" "))) # -P 2
    }
    stopCluster(cl)
}

regrid(ipath = "/QRISdata/Q1215/ClimateModels/CMIP6_raw/MPI-ESM1-2-HR/ssp126/Omon/ph/", 
       opath = "/gpfs1/scratch/30days/uqibrito/Project05c_Anne/ClimateModels/models_regrid/", 
       resolution = "0.25")

