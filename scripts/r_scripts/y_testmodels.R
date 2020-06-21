library(raster)
library(dplyr)

files <- list.files(path = "CMIP6_zrasters_r1i1p1f1/ssp126/05_BottomLayer", pattern = ".grd", full.names = TRUE)
for(i in 1:length(files)) {
  
  rs <- raster(files[i]) %>% 
    subset(1)
  ns <- basename(files[i])
  olayer <- unlist(strsplit(ns, "_"))[1]
  var <- unlist(strsplit(ns, "_"))[2]
  model <- unlist(strsplit(ns, "_"))[3]
  rcp <- unlist(strsplit(ns, "_"))[4]
  name.rs <- paste(olayer, var, model, rcp, sep = "_")
  
  pdf(paste("CMIP6_zrasters_r1i1p1f1/ssp126/05_BottomLayer/", name.rs, ".pdf", sep = ""), width = 10, height = 8)
  plot(rs)
  dev.off()
}

