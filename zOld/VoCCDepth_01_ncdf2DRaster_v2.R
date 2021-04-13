# This code was written by Isaac Brito-Morales (i.britomorales@uq.edu.au)
# Please do not distribute this code without permission.
# NO GUARANTEES THAT CODE IS CORRECT
# Caveat Emptor!

# AIM = # Parallel Function that reads a 3 dimensional netCDF file (long, lat, time) and returns rasterstacks (years)
# path = directory of netCDF files
# outdir = where to allocate files by model
# from = initial year of netCDF files
# to = end year of netCDF files
  
  par_ncdf_2D_rs <- function(path, outdir, from, to) {
    
    library(doParallel)
    library(foreach)
    library(raster)
    library(ncdf4)
    library(ncdf4.helpers)
    library(PCICt)
    
    ncdf_2D_rs <- function(nc, v = "thetao", x = "lon", y = "lat") {
     
      # Extract data from the netCDF file  
       nc <- nc_open(nc)
        dat <- ncvar_get(nc, v) # x, y, year 
        dat[] <- dat
        X <- dim(dat)[1]
        Y <- dim(dat)[2]
        tt <- nc.get.time.series(nc, v = "time", time.dim.name = "time") # from packages ncdf4.helpers&PCICt
          tt <- as.POSIXct(tt)
          tt <- as.Date(tt)
        nc_close(nc)
        rs <- raster(nrow = Y, ncol = X) # Make a raster with the right dims to fill with lat&lon
      # Fix orientation of original data [and then create a raster with this fix orientation and paste deths and time...]
        drs <- data.frame(coordinates(rs))
      # Create rasters stacks of depths for every month
        rs_list <- list() # empty list to allocate results
        st <- stack()
        for (i in 1:length(tt)) {
          dt1 <- rasterFromXYZ(cbind(drs, as.vector(dat[,, i])))
            dt1[]<- ifelse(dt1[] <= -2, NA, dt1[]) # for some models that have weird temperatures (-273)
            dt1[]<- ifelse(dt1[] >= 40, NA, dt1[])
          st <- addLayer(st, flip(dt1, 2))
          print(paste0(i, " of ", length(tt)))
        }
      names(st) <- seq(as.Date(paste(from, "1", "1", sep = "/")), as.Date(paste(to, "12", "1", sep = "/")), by = "month")
      crs(st) <- "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"
      # name.rs <- paste(v, model, rcp, rrun, yrs, ".grd", sep = "_")
      return(st)
    }
    
    # Climate Models Directory
      dir.nc <- paste(list.dirs(path = path, full.names = TRUE, recursive = FALSE))
      # Do a parallel analysis for every climatic folder
        for(kk in 1:length(dir.nc)) { 
          # Files directory
            files.nc <- paste(dir.nc[kk], list.files(path = paste(dir.nc[kk], sep = "/"), pattern = ".nc"), sep = "/")
            files_list <- list() # to allocate results
          # Begin the parallel structure
            UseCores <- 10 # Define how many cores
            cl <- makeCluster(UseCores)
            registerDoParallel(cl) # Register CoreCluster
            # Parallel Loop
              rs_list <- foreach(i = 1:length(files.nc), .packages = c("raster", "ncdf4", "ncdf4.helpers", "PCICt")) %dopar% {
                # Transform a netCDF file into a raster
                  single <- ncdf_2D_rs(files.nc[i])
                # Defining  files' name
                  ns <- basename(files.nc[i])
  		              olayer <- unlist(strsplit(ns, "_"))[1]
  		              var <- unlist(strsplit(ns, "_"))[2]
  		              model <- unlist(strsplit(ns, "_"))[4]
  		              rcp <- unlist(strsplit(ns, "_"))[5]
  		              ensm <- unlist(strsplit(unlist(strsplit(ns, "_"))[6], ".nc"))
		              name.rs <- paste(olayer, var, model, rcp, ensm, paste(from, to, sep = "-"), sep = "_")
                # Writing Raster for every depth and model
                  writeRaster(single, paste(outdir, name.rs, ".grd", sep = ""), overwrite = TRUE)
              }
              stopCluster(cl)
        }
      return(rs_list)
  }
  
  system.time(par_ncdf_2D_rs(path = "models_regrid_zmerge/ssp126",
                             outdir = "models_regrid_zmerge/ssp126/",
                             from = "2015",
                             to = "2100"))

  
