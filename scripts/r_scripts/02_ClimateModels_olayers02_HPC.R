# This code was written by Isaac Brito-Morales (i.britomorales@uq.edu.au)
# Please do not distribute this code without permission.
# NO GUARANTEES THAT CODE IS CORRECT
# Caveat Emptor!

# Function's arguments
# ipath: directory where the netCDF files are located
# opath: directory to allocate the new regrided netCDF files
# resolution = resolution for the regrid process

olayer <- function(ipath, opath1, opath2) {

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
  # Parallel looop
    cl <- makeCluster(10)
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
      # Some can come in cm
        if(depths[1] >= 50) { 
          sf <- depths[as.numeric(depths) <= 500]
          ep <- depths[as.numeric(depths) >= 0 & as.numeric(depths) <= 20000]
          mp <- depths[as.numeric(depths) > 20000 & as.numeric(depths) <= 100000]
          bap <- depths[as.numeric(depths) > 100000]
        } else {
          sf <- depths[as.numeric(depths) <= 5]
          ep <- depths[as.numeric(depths) >= 0 & as.numeric(depths) <= 200]
          mp <- depths[as.numeric(depths) > 200 & as.numeric(depths) <= 1000]
          bap <- depths[as.numeric(depths) > 1000]
        }
      # Running CDO
        # Surface
          system(paste(paste("cdo -L -sellevel,", 
                             paste0(sf, collapse = ","), ",", sep = ""), 
                       paste("-selname,", var, sep = ""), files.nc[j], 
                       paste0(opath1, "01-sf_", basename(files.nc[j]))))
        # Epipelagic
          system(paste(paste("cdo -L -sellevel,", 
                             paste0(ep, collapse = ","), ",", sep = ""), 
                       paste("-selname,", var, sep = ""), files.nc[j], 
                       paste0(opath1, "02-ep_", basename(files.nc[j]))))
        # Mesopelagic
          system(paste(paste("cdo -L -sellevel,", 
                             paste0(mp, collapse = ","), ",", sep = ""), 
                       paste("-selname,", var, sep = ""), files.nc[j], 
                       paste0(opath1, "03-mp_", basename(files.nc[j]))))
        # Bathypelagic
          system(paste(paste("cdo -L -sellevel,", 
                             paste0(bap, collapse = ","), ",", sep = ""), 
                       paste("-selname,", var, sep = ""), files.nc[j], 
                       paste0(opath1, "04-bap_", basename(files.nc[j]))))
    }
    stopCluster(cl)
    
####################################################################################
####### Getting the path and directories for the "split by depth" files
####################################################################################
  # Establish the find bash command
    line1.1 <- paste(noquote("find"), noquote(opath1), "-type", "f", "-name", noquote("*.nc"), "-exec", "ls", "-l", "{}")
    line2.1 <- paste0("\\", ";")
    line3.1 <- paste(line1.1, line2.1)
  # Getting a list of directories for every netCDF file
    dir_files.2 <- system(line3.1, intern = TRUE)
    dir_nc.2 <- strsplit(x = dir_files.2, split = " ")
    final_nc.2 <- lapply(dir_nc.2, function(x){f1 <- tail(x, n = 1)})
    files.nc.2 <- unlist(final_nc.2)
    
####################################################################################
####### Filtering by layers and generating the "weighted-average depth layer" netCDF files
#################################################################################### 
  # Parallel looop
    cl <- makeCluster(10)
    registerDoParallel(cl)
    foreach(i = 1:length(files.nc.2), .packages = c("stringr")) %dopar% {
      # Running CDO
        system(paste(paste("cdo -L vertmean", sep = ""), files.nc.2[i], 
                     paste0(opath2, basename(files.nc.2[i])), sep = (" ")))
    }
    stopCluster(cl)
}

olayer(ipath = "/gpfs1/scratch/30days/uqibrito/models_regrid/",
       opath1 = "/gpfs1/scratch/30days/uqibrito/models_regrid_layers/", 
       opath2 = "/gpfs1/scratch/30days/uqibrito/models_regrid_vertmean/")
