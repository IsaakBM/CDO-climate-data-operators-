
	ipath <- "/Users/bri273/Desktop/latest/" # Input path
	opath <- "/Users/bri273/Desktop/latest2/" # Output path
	f <- dir(ipath, pattern = "*.nc") # All the OISST data 0-360
	grd <- dir(ipath, pattern = "*.grd") # All the OISST data 0-360
	for (i in 1:length(f)) {
	  ifile <- paste0(ipath, f[i])
	  grdfile <- paste0(ipath, grd)
	  ofile <- paste0(opath, f[i])
	  # system(paste("cdo yearmean", ifile, ofile, sep = (" ")))
	  system(paste(paste("cdo remapbil,", grdfile, ",", sep = ""), ifile, ofile, sep = (" ")))
		}
	
	
	
	library(doParallel)
	library(parallel)
	
	ipath <- "/Users/bri273/Desktop/latest/" # Input path
	opath <- "/Users/bri273/Desktop/latest2/" # Output path
	f <- dir(ipath, pattern = "*.nc") # All the OISST data 0-360
	grd <- dir(ipath, pattern = "*.grd") # All the OISST data 0-360
	
	UseCores <- detectCores() -1
	cl <- makeCluster(UseCores)  
	registerDoParallel(cl)
	
	foreach(i = 1:length(f))  %dopar% { 
	  ifile <- paste0(ipath, f[1])
	  grdfile <- paste0(ipath, grd)
	  ofile <- paste0(opath, f[i])
	  # system(paste("cdo yearmean", ifile, ofile, sep = (" ")))
	  system(paste(paste("cdo remapbil,", grdfile, ",", sep = ""), ifile, ofile, sep = (" ")))
	}
	
	
	ipath <- "/Users/bri273/Desktop/testing" # Input path
	opath <- "/Users/bri273/Desktop/testing/" # Output path
	dir.nc <- paste(list.dirs(path = ipath, full.names = TRUE, recursive = FALSE))
	
	for(i in 1:length(dir.nc)) {
	  
	  file.grd <- paste(dir.nc[i], list.files(path = paste(dir.nc[i], sep = "/"), pattern = "*.grd"), sep = "/")
	  files.nc <- paste(dir.nc[i], list.files(path = paste(dir.nc[i], sep = "/"), pattern = "*.nc"), sep = "/")
	  
	  UseCores <- detectCores() -1
	  cl <- makeCluster(UseCores)  
	  registerDoParallel(cl)
	  
	  foreach(j = 1:length(files.nc)) %dopar% {
	    
	    system(paste(paste("cdo remapbil,", file.grd, ",", sep = ""), files.nc[j], paste0(opath, basename(files.nc[j])), sep = (" ")))
	    
	  } 
	  
	}
	
	
	
	
	
	