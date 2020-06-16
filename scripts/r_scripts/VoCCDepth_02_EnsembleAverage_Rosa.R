# This code was written by Isaac Brito-Morales (i.britomorales@uq.edu.au)
# Please do not distribute this code without permission.
# NO GUARANTEES THAT CODE IS CORRECT
# Caveat Emptor!

# AIM = Creates an ensemble average model from different climatic models
# path = raster files directory location
# outdir = where to allocate files by model
# from = initial year of raster file
# to = end year of raster files
# bathymetry = ETOPOS shapefile

model.mean <- function(path, outdir, from, to, bathymetry) {
  # Packages
  library(raster)
  library(doParallel)
  library(foreach)
  library(dplyr)
  library(stringr)
  
  # Function to stack a list of rasters     
    staking <- function(dat) {
      d <- stack(dat[[1]])
      for (m in 2:length(dat)) { 
        d <- addLayer(d, dat[[m]])}
      names(d)<- names.yrs
      crs(d) <- "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"
      return(d)
    }
  
  # Bathymetry layers
  etopo <- raster(bathymetry)
    bathy_sf <- bathy_ep <- bathy_mp <- bathy_bap <- etopo
    bathy_sf[] <- ifelse(etopo[] > 0, NA, etopo[])
    bathy_ep[] <- ifelse(etopo[] > 0, NA, etopo[])
    bathy_mp[] <- ifelse(etopo[] > -200, NA, etopo[])
    bathy_bap[] <- ifelse(etopo[] > -1000, NA, etopo[])
  bathy <- stack(bathy_sf, bathy_ep, bathy_mp, bathy_bap)

  # Climate Models Depth Layers Directory
    dir.layers <- paste(list.dirs(path = path, full.names = TRUE, recursive = FALSE), sep = "/")
    
    for(kk in 1:length(dir.layers)) { 
      # Get the files for the first directory
        files_rs <- paste(dir.layers[kk], list.files(path = paste(dir.layers[kk], sep = "/"), pattern = ".grd"), sep = "/")
        # Define time period to work with
          # names.yrs <- paste("X", as.character(seq(from, to)), sep = "")
          names.yrs <- paste("X", seq(as.Date(paste(from, "1", "1", sep = "/")), as.Date(paste(to, "12", "1", sep = "/")), by = "month"), sep = "") %>% 
            str_replace_all(pattern = "-", replacement = ".")
          rs_multi <- vector("list", length(files_rs))
          # Loop to read every file and change resolution if you want or subset a particular time
            for (k in 1:length(files_rs)) {
              rs <- stack(files_rs[k])
              if (res(rs)[1] != 0.5) { # == 0.25 if models came in high-res, standardised them at 1x1 degree of latitude aggregating by the mean
                rs1 <- raster::aggregate(rs, 2)
                  rs1 <- raster::subset(rs, names.yrs)
              } else {rs1 <- raster::subset(rs, names.yrs)}
              rs_multi[k] <- rs1 # add those rasters to a list element
            }
          
            # Create rasterstacks of models by "time" (same year/month by each model)
              names.yrs <- names(rs_multi[[1]])
              st <- stack()
              rs_multi02 <- list()
              for (i in 1:length(names.yrs)) {
                for (j in 1:length(rs_multi)) {
                  if (j == 1) {
                    dt <- subset(rs_multi[[j]], names.yrs[i]) # subset every rasterstacks element of the list
                    st1 <- dt
                  } else {
                    dt <- subset(rs_multi[[j]], names.yrs[i]) # same again!
                    st1 <- stack(st1, dt)
                  }
                }
                rs_multi02[i] <- st1
              }
            
            # Estimate mean and SD by year to get our model-ensemble means [this function needs to be parallelized]
              model.mean <- list()
              # Begin the parallel structure
                UseCores <- detectCores() -1 # Define how many cores
                cl <- makeCluster(UseCores)  
                registerDoParallel(cl) # Register CoreCluster
                # Parallel Loop
                  rs_list <- foreach(l = 1:length(rs_multi02), .packages = c("raster")) %dopar% {
                    model.mean[l] <- stackApply(rs_multi02[[l]], indices = rep(1, nlayers(rs_multi02[[l]])), 
                                                fun = function(x, ...) mean(x, na.rm = FALSE)) # FALSE: keep same cell structure; TRUE: different cell structure across models
                  }
                  stopCluster(cl)
            # Create a ensemble-model average
              rs_list_b <- unlist(rs_list)
              final.mean <- staking(rs_list_b)
              # Bathymetry to "adjust" cells with ETOPO1 layer at 1°
                for(b in 1:nlayers(final.mean)) {
                  if(b == 1) {
                    single <- subset(final.mean, b)
                    dt1 <- mask(single, resample(subset(bathy, kk), single, resample = "ngb"))
                    st1 <- dt1
                    } else {
                      single <- subset(final.mean, b)
                      dt1 <- mask(single, resample(subset(bathy, kk), single, resample = "ngb"))
                      st1 <- stack(st1, dt1)
                    }
                  }
                
              # Writing ensemble model
                ns <- basename(files_rs[k])
                  var <- unlist(lapply(ns, FUN = function(x) strsplit(x, "_")[[1]][[2]]))
                  olayer <- unlist(lapply(ns, FUN = function(x) strsplit(x, "_")[[1]][[1]]))
                  rcp <- unlist(lapply(ns, FUN = function(x) strsplit(x, "_")[[1]][[4]]))
                  name.rs <- paste(olayer, var, "AEMean", rcp, "r1i1p1f1", paste(from, to, sep = "-"), sep = "_")
                writeRaster(st1, paste(outdir, name.rs, ".grd", sep = ""), overwrite = TRUE)
          }
  }


  system.time(model.mean(path = "/Users/bri273/Desktop/CDO/CMIP6_zrasters_r1i1p1f1/ssp126",
                         outdir = "/Users/bri273/Desktop/CDO/CMIP6_zrasters_r1i1p1f1/ssp126/",
                         from = "2015",
                         to = "2100",
                         bathymetry = "/Users/bri273/Desktop/VoCC_Prioritizr_global/shapefiles_rasters/ETOPO1_05deg/ETOPO1_ocean.grd"))


  
