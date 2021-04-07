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
####### 
####################################################################################
  # 
    line1 <- paste(noquote("find"), noquote(ipath), "-type", "f", "-name", noquote("*.nc"), "-exec", "ls", "-l", "{}")
    line2 <- paste0("\\", ";")
    line3 <- paste(line1, line2)
  # 
    dir_files <- system(line3, intern = TRUE)
    dir_vector <- strsplit(x = dir_files, split = " ")
    dir_nc <- lapply(dir_vector, function(x) x[13])
  # 
    final_nc <- lapply(dir_nc, function(x) {
      c1 <- str_split(unlist(x), pattern = "//")
      c2 <- paste(c1[[1]][1], c1[[1]][2], sep = "/")})
    files.nc <- unlist(final_nc)
  # 
    var_obj <- system(paste("cdo -showname", final_nc[1]), intern = TRUE)[1]
    var <- str_replace_all(string = var_obj, pattern = " ", replacement = "")
 
####################################################################################
####### 
#################################################################################### 
  # 
    if(resolution == "1") {
      grd <- "r360x180"
    } else if(resolution == "0.5") {
      grd <- "r720x360"
    } else if(resolution == "0.5") {
      grd <- "r1440x720"
    }
    
  # 
    UseCores <- 3
    cl <- makeCluster(UseCores)  
    registerDoParallel(cl)
    foreach(j = 1:length(files.nc)) %dopar% {
      system(paste(paste("cdo -remapbil,", grd, ",", sep = ""), 
                   paste("-selname",var, sep = ","), files.nc[j], 
                   paste0(opath, basename(files.nc[j])), sep = (" ")))
    }
    stopCluster(cl)
}

regrid(ipath = "/Users/bri273/Desktop/CDO/models_raw/ssp126/ACCESS-CM2/", 
       opath = "/Users/bri273/Desktop/CDO/models_raw/", 
       resolution = "1")
