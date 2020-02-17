library(doParallel)
library(parallel)

ipath <- "/QRISdata/Q1216/BritoMorales/zztest/regrid" # Input path
opath <- "/QRISdata/Q1216/BritoMorales/zztest/regrid/" # Output path

dir.nc <- paste(list.dirs(path = ipath, full.names = TRUE, recursive = FALSE))

for(i in 1:length(dir.nc)) {
  
  file.grd <- paste(dir.nc[i], list.files(path = paste(dir.nc[i], sep = "/"), pattern = "*.grd"), sep = "/")
  files.nc <- paste(dir.nc[i], list.files(path = paste(dir.nc[i], sep = "/"), pattern = "*.nc"), sep = "/")
  
  UseCores <- 21
  cl <- makeCluster(UseCores)  
  registerDoParallel(cl)
  
  foreach(j = 1:length(files.nc)) %dopar% {
    
    system(paste(paste("cdo remapbil,", file.grd, ",", sep = ""), files.nc[j], paste0(opath, basename(files.nc[j])), sep = (" ")))
    
  } 
  stopCluster(cl)
}



##### defining ocean layers using CDO in bash mode + R to get levels and then write files

infile <- "/Users/bri273/Desktop/testing/thetao_Omon_ACCESS-CM2_ssp126_r1i1p1f1_gn_201501-202412.nc"
outfile <- "/Users/bri273/Desktop/testing/mp_thetao_Omon_ACCESS-CM2_ssp126_r1i1p1f1_gn_201501-202412.nc"
levels <- as.vector(system(paste("cdo showlevel", infile), intern = TRUE))

depths <- unlist(strsplit(levels, split = " "))
depths <- unique(depths[depths != ""])

sf <- depths[as.numeric(depths) <= 5]
ep <- depths[as.numeric(depths) > 5 & as.numeric(depths) <= 200]
mp <- depths[as.numeric(depths) > 200 & as.numeric(depths) <= 1000]
bp <- depths[as.numeric(depths) > 1000 & as.numeric(depths) <= 4000]
abp <- depths[as.numeric(depths) > 4000]

system(paste(paste("cdo -sellevel,", paste(mp, collapse = ","), ",", sep = ""), paste("-selname,", "thetao", sep = ""), infile, outfile))




