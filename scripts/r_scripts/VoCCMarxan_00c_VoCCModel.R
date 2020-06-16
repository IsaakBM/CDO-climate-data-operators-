# This code was written by Isaac Brito-Morales (i.britomorales@uq.edu.au)
# Please do not distribute this code without permission.
# NO GUARANTEES THAT CODE IS CORRECT
# Caveat Emptor!

# AIM =  A parallelized function that will estimate the velocity of climate change components (km decade-1) 
  # path = raster files directory location
  # outdir = where to allocate vocc rasterstacks files
  # variable = variable's name
  # region =  
  # from = initial year to estimate VoCC
  # to = final year to get the period to estimate VoCC

  vocc_model <- function(path, outdir, variable, region, flip, from, to, ...) {
    
    library(doParallel)
    library(foreach)
    library(raster)
    library(VoCC)
    library(kader)
    library(dplyr)
    library(stringr)
    
    # Function that will flip a raster (was thinking for models at 0.5deg like MPI-ESM1-2-HR)
      flip_rs <- function(data) {
        for (i in 1:nlayers(data)) {
          if (i == 1) {
            single <- subset(data, i)
            rs <- as.data.frame(rasterToPoints(single))
              rs[,1] <- ifelse(rs[,1] < 0, rs[,1] + 180, rs[,1] - 180)
              rs2 <- rasterFromXYZ(rs)
              st <- rs2
              } else {
                single <- subset(data, i)
                rs <- as.data.frame(rasterToPoints(single))
                rs[,1] <- ifelse(rs[,1] < 0, rs[,1] + 180, rs[,1] - 180)
                rs2 <- rasterFromXYZ(rs)
                st <- stack(st, rs2)
              }
          }
        return(st)
        }
    
    # Climate Models Directory
      dir.layers <- paste(list.dirs(path = path, full.names = TRUE, recursive = FALSE), sep = "/") # add or not layer folder?
    # Create a ext object to use it latter for crop if the projection is not a world map
      region <- raster(region)
      ext <- extent(region)
      # Loop every model
        for(kk in 1:length(dir.layers)) {
          files_rs <- paste(dir.layers[kk], list.files(path = paste(dir.layers[kk], sep = "/"), pattern = ".grd"), sep = "/")
          # Define time period to estimate climate velocity
            # names.yrs <- paste("X", as.character(seq(from, to)), sep = "")
            names.yrs <- paste("X", seq(as.Date(paste(from, "1", "1", sep = "/")), as.Date(paste(to, "12", "1", sep = "/")), by = "month"), sep = "") %>%
              str_replace_all(pattern = "-", replacement = ".")
            rs_multi <- vector("list", length(files_rs))
            # Loop through every depth file per model and subset the period of interest
              for (k in 1:length(files_rs)) {
                rs <- stack(files_rs[k])
                if (flip == TRUE) {
                  rs <- flip_rs(rs)
                  rs1 <- raster::subset(rs, names.yrs)
                    index <- rep(1:nlayers(rs1), each = 12, length.out = nlayers(rs1))
                    rs2 <- stackApply(x = rs1, indices = index, fun = mean)
                  rs_multi[k] <- rs2
                } else {
                  rs1 <- raster::subset(rs, names.yrs)
                    index <- rep(1:nlayers(rs1), each = 12, length.out = nlayers(rs1))
                    rs2 <- stackApply(x = rs1, indices = index, fun = mean)
                  rs_multi[k] <- rs2
                }
              }
            
            # A simple step to crop the raster if the projection is not a world map
              rs_multi <- lapply(rs_multi, function(x) {if (ext@xmin > -180 & ext@xmax < 180 & ext@ymin > -90 & ext@ymax < 90) {rs <- crop(x, ext) } else {rs <- x}})

          # Calculate VoCC for every depth
            list.vocc <- vector("list", length(rs_multi)) # to allocate results
            # Begin the parallel structure
              UseCores <- detectCores() -1 # Define how many cores
              cl <- makeCluster(UseCores)  
              registerDoParallel(cl) # Register CoreCluster
              # Parallel Loop
                rs_list <- foreach(j = 1:length(rs_multi), .packages = c("raster", "VoCC", "dplyr")) %dopar% { 
                    rs <- rs_multi[[j]]
                  # Calculate VoCC for every depth
                    # Temporal trend  
                      a <- tempTrend(rs, th = 10)
                    # Spatial gradient
                      b <- spatGrad(rs, th = 0.0001, projected = FALSE)
                    # VoCC local gradient
                      c <- gVoCC(a,b)
                      c$voccMag[] <- ifelse(is.infinite(c$voccMag[]), NA, c$voccMag[]) # replace inf with NAs (just in case)
                    # Writing VoCC rasters by depth
                      ns <- basename(files_rs[k])
                        var1 <- paste("voccMag", unlist(strsplit(ns, "_"))[1], sep = "_")
                        var2 <- paste("slpTrends", unlist(strsplit(ns, "_"))[1], sep = "_")
                        var3 <- paste("seTrends", unlist(strsplit(ns, "_"))[1], sep = "_")
                        model <- unlist(strsplit(ns, "_"))[3]
                        rcp <- unlist(strsplit(ns, "_"))[4]
                        ensm <- unlist(strsplit(ns, "_"))[5]
                      name.rs1 <- paste(var1, model, rcp, ensm, paste(from, to, sep = "-"), sep = "_")
                      name.rs2 <- paste(var2, model, rcp, ensm, paste(from, to, sep = "-"), sep = "_")
                      name.rs3 <- paste(var3, model, rcp, ensm, paste(from, to, sep = "-"), sep = "_")
                      
                      writeRaster(c[[1]], paste(outdir, name.rs1, "_.tif", sep = ""), overwrite = TRUE)
                      writeRaster(a[[1]], paste(outdir, name.rs2, "_.tif", sep = ""), overwrite = TRUE)
                      writeRaster(a[[2]], paste(outdir, name.rs3, "_.tif", sep = ""), overwrite = TRUE)
                    
                  # Calculate Trajectories for every depth
                    # The mean of the whole period
                      mn <- mean(rs, na.rm = T)
                    # get the set of starting cells for the trajectories
                      lonlat <- na.omit(data.frame(xyFromCell(c[[1]], 1:ncell(c[[1]])), c[[1]][], c[[2]][], mn[]))[,1:2]
                    # Calculate trajectories.
                      traj <- voccTraj(lonlat, c[[1]], c[[2]], mn = mn, tyr = nlayers(rs), correct = TRUE)
                      clas <- trajClas(traj, c[[1]], c[[2]], mn = mn, trajSt = 16, tyr =  nlayers(rs), nmL = 20, smL = 100, Nend = 45, Nst = 15, NFT = 70)
                      # my_col <- c('gainsboro','darkseagreen1','coral4','firebrick2','mediumblue','darkorange1','magenta1','cadetblue1','yellow1')
                    # Isolate trajectory classes for individual rasters
                      r <- ratify(clas[[7]]) # trajectory class from the stack element
                      rat_r <-levels(r)[[1]] # numbers for classes
                      rat_r$trajcat <- c("non-moving", 
                                         "slow-moving", 
                                         "internal-sinks", 
                                         "boundary-sinks", 
                                         "sources", 
                                         "relative-sinks", 
                                         "corridors",
                                         "divergence",
                                         "convergence")[sort(unique(clas[[7]][]))] # extract the appropiate classes from the raster
                      levels(r) <- rat_r
                      # names for loop and for writing raster
                        traj_features <- levels(r)[[1]][[1]]
                        traj_names <- levels(r)[[1]][[2]]
                      # Loop to get individuals rasters
                        traj_list <- vector("list", length(traj_features))
                        for(i in 1:length(traj_features)) {
                          single <- r
                          single[] <- ifelse(single[] == traj_features[i], single[], NA)
                          var.traj <- paste(traj_names[i], unlist(strsplit(ns, "_"))[1], sep = "_")
                          name.traj <- paste(var.traj, model, rcp, ensm, paste(from, to, sep = "-"), sep = "_")
                          writeRaster(single, paste(outdir, name.traj, "_.tif", sep = ""), overwrite = TRUE)
                        }
                }
                stopCluster(cl)
        }
    }
  
  # FOR AVERAGE MODEL
    # Same cell structure across models 
      system.time(vocc_model(path = "/QRISdata/Q1216/BritoMorales/Project04b/CMIP6_zrasters_zensemble/thetao_05deg/ssp126",
                             outdir = "/QRISdata/Q1216/BritoMorales/Project04b/CMIP6_zrasters_zensemble/thetao_05deg/ssp126/",
                             variable = "thetao",
                             region = "/QRISdata/Q1216/BritoMorales/Project04b/ETOPO1_05deg/ETOPO1_ocean.grd",
                             flip = TRUE,
                             from = "2020",
                             to = "2100"))
  
  # # FOR EVERY MODEL
  #   system.time(vocc_model(path = "/Users/bri273/Desktop/VOCC_Depths-master/annualrasters2(noCNRMGISSH)/rcp85",
  #                          outdir = "/Users/bri273/Desktop/VOCC_Depths-master/annualvoccModels/rcp85/",
  #                          variable = "thetao",
  #                          from = "2050",
  #                          to = "2100"))
  
  
  