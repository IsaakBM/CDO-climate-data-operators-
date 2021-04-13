library(raster)
ep <- stack("CMIP6_zrasters_r1i1p1f1/ssp126/02-ep_thetao_AEMean_ssp126_r1i1p1f1_2015-2100.grd")
plot(ep$X2015.01.01)

files_rs <- list.files(path = "CMIP6_zrasters_r1i1p1f1/ssp126/02_EpipelagicLayer", pattern = ".grd", full.names = TRUE)
outdir <- "CMIP6_zrasters_r1i1p1f1/ssp126/02_EpipelagicLayer/"
for(i in 1:length(files_rs)) {
  
  single <- stack(files_rs[i])
  rs <- subset(single, 1)
  
  ns <- basename(files_rs[i])
  olayer <- unlist(strsplit(ns, "_"))[1]
  var <- unlist(strsplit(ns, "_"))[2]
  model <- unlist(strsplit(ns, "_"))[3]
  rcp <- unlist(strsplit(ns, "_"))[4]
  ensm <- unlist(strsplit(unlist(strsplit(ns, "_"))[5], ".nc"))
  name.rs <- paste(olayer, var, model, rcp, ensm, paste("2015", "2100", sep = "-"), sep = "_")
  
  pdf(paste(outdir, name.rs, ".pdf", sep = ""), height = 10, width = 20)
  plot(rs)
  dev.off()
  
  
}


library(raster)
ep <- stack("models_regrid_zmerge/ssp126/02-ep_thetao_ACCESS-ESM1-5_ssp126_r1i1p1f1_2015-2100.grd")
plot(ep$X2015.01.01)

index <- rep(1:nlayers(ep), each = 12, length.out = nlayers(ep))
ep_annual <- stackApply(x = ep, indices = index, fun = mean)

plot(ep_annual$index_1)
plot(ep_annual$index_86)


ep2 <- stack("CMIP6_zrasters_r1i1p1f1/ssp126/02-ep_thetao_AEMean_ssp126_r1i1p1f1_2015-2100.grd")

names.yrs <- paste("X", seq(as.Date(paste(2015, "1", "1", sep = "/")), as.Date(paste(2020, "12", "1", sep = "/")), by = "month"), sep = "") %>% 
  str_replace_all(pattern = "-", replacement = ".")
  
test <- subset(ep2, names.yrs)
index2 <- rep(1:nlayers(test), each = 12, length.out = nlayers(test))
test_min <- stackApply(x = test, indices = index2, fun = min)
plot(test_min$index_1)
test_max <- stackApply(x = test, indices = index2, fun = max)

test_range <- test_max - test_min

plot(test_range$index_1)

test_range_mean <- stackApply(x = test_range, indices = nlayers(test_range), fun = mean)
plot(test_range_mean)


######
from = "2020"
to = "2100"
outdir = "CMIP6_zrasters_r1i1p1f1/ssp126/"

names.yrs <- paste("X", seq(as.Date(paste(from, "1", "1", sep = "/")), as.Date(paste(to, "12", "1", sep = "/")), by = "month"), sep = "") %>%
  str_replace_all(pattern = "-", replacement = ".")
rs <- stack("CMIP6_zrasters_r1i1p1f1/ssp126/02-ep_thetao_AEMean_ssp126_r1i1p1f1_2015-2100.grd")

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

rs1 <- raster::subset(rs, names.yrs)
rs1 <- flip_rs(rs1)
index <- rep(1:nlayers(rs1), each = 12, length.out = nlayers(rs1))
rs2 <- stackApply(x = rs1, indices = index, fun = mean)

a <- tempTrend(rs2, th = 10)
b <- spatGrad(rs2, th = 0.0001, projected = FALSE)
c <- gVoCC(a,b)
c$voccMag[] <- ifelse(is.infinite(c$voccMag[]), NA, c$voccMag[]) # replace inf with NAs (just in case)

ns <- basename("CMIP6_zrasters_r1i1p1f1/ssp126/02-ep_thetao_AEMean_ssp126_r1i1p1f1_2015-2100.grd")
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

slp <- raster("CMIP6_zrasters_r1i1p1f1/ssp126/slpTrends_02-ep_AEMean_ssp126_r1i1p1f1_2020-2100_.tif")
slp2 <- ((slp*10)*8)
plot(slp2)

names.yrs2 <- paste("X", seq(as.Date(paste(2015, "1", "1", sep = "/")), as.Date(paste(2020, "12", "1", sep = "/")), by = "month"), sep = "") %>% 
  str_replace_all(pattern = "-", replacement = ".")

rs3 <- raster::subset(rs, names.yrs2)
rs3.b <- flip_rs(rs3)
index2 <- rep(1:nlayers(rs3.b), each = 12, length.out = nlayers(rs3.b))

rs3_min <- stackApply(x = rs3.b, indices = index2, fun = min)
plot(rs3_min$index_1)
rs3_max <- stackApply(x = rs3.b, indices = index2, fun = max)
plot(rs3_max$index_1)

rs3_range <- rs3_max - rs3_min
plot(rs3_range$index_1)

rs3_range_range_mean <- stackApply(x = rs3_range, indices = nlayers(rs3_range), fun = mean)
plot(rs3_range_range_mean)

test <- slp2/rs3_range_range_mean
plot(kader:::cuberoot(test$layer))

writeRaster(test, "CMIP6_zrasters_r1i1p1f1/ssp126/RCE_02-ep_AEMean_ssp126_r1i1p1f1_2015-2020_.tif")

non126 <- raster("CMIP6_zrasters_r1i1p1f1/ssp126/non-moving_02-ep_AEMean_ssp126_r1i1p1f1_2020-2100_.tif")
plot(non126)
non245 <- raster("CMIP6_zrasters_r1i1p1f1/ssp126/non-moving_02-ep_AEMean_ssp245_r1i1p1f1_2020-2100_.tif")
plot(non245)


