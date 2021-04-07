library(doParallel)
library(parallel)
library(stringr)
library(data.table)

ipath <- "/QRISdata/Q1215/ClimateModels/CMIP6_rclean/thetao/ssp585"
opath <- "/QRISdata/Q1215/ClimateModels/CMIP6_rclean_regrid/thetao_05deg/ssp585/"

#ipath <- "/QRISdata/Q1215/ClimateModels/CMIP6_rclean/tob/ssp126"
#opath <- "/QRISdata/Q1215/ClimateModels/CMIP6_rclean_regrid/tob_05deg/ssp126/"

#ipath <- "/QRISdata/Q1215/ClimateModels/CMIP6_rclean/ph/ssp126"
#opath <- "/QRISdata/Q1215/ClimateModels/CMIP6_rclean_regrid/ph_05deg/ssp126/"

dir.nc <- paste(list.dirs(path = ipath, full.names = TRUE, recursive = FALSE))

for(i in 1:length(dir.nc)) {
  file.grd <- paste(dir.nc[i], list.files(path = paste(dir.nc[i], sep = "/"), pattern = "*.grd"), sep = "/")
  files.nc <- paste(dir.nc[i], list.files(path = paste(dir.nc[i], sep = "/"), pattern = "*.nc"), sep = "/")
  
  UseCores <- 2 #5
  cl <- makeCluster(UseCores)  
  registerDoParallel(cl)
  
  foreach(j = 1:length(files.nc)) %dopar% {
     system(paste(paste("cdo -P 2 -remapbil,", file.grd, ",", sep = ""), paste("-selname","thetao", sep = ","), files.nc[j], paste0(opath, basename(files.nc[j])), sep = (" ")))
    # system(paste(paste("cdo -P 10 -remapbil,", file.grd, ",", sep = ""), paste("-selname","tob", sep = ","), files.nc[j], paste0(opath, basename(files.nc[j])), sep = (" ")))
    #system(paste(paste("cdo -P 10 -remapbil,", file.grd, ",", sep = ""), paste("-selname","ph", sep = ","), files.nc[j], paste0(opath, basename(files.nc[j])), sep = (" ")))
  } 
  stopCluster(cl)
}

# module load R/3.5.0-intel gurobi/9.0.2
# cdo remapbil,1deg.grd, -selname,thetao [paste("-selname","thetao", sep = ",")]
# 
ipath <- "/Users/bri273/Desktop/CDO/models_raw/ssp126/ACCESS-CM2/"
ipath <- "models_raw/ssp126/"

line1 <- paste(noquote("find"), noquote(ipath), "-type", "f", "-name", noquote("*.nc"), "-exec", "ls", "-l", "{}")
line2 <- paste0("\\", ";")
line3 <- paste(line1, line2)

dir_files <- system(line3, intern = TRUE)
dir_vector <- strsplit(x = dir_files, split = " ")
dir_nc <- lapply(dir_vector, function(x) x[13])

final_nc <- lapply(dir_nc, function(x) {
  c1 <- str_split(unlist(x), pattern = "//")
  c2 <- paste(c1[[1]][1], c1[[1]][2], sep = "/")
})
final_nc <- unlist(final_nc)

system(paste("cdo -sinfo", final_nc[1]))



a <- system(paste("cdo -showname", final_nc[1]), intern = TRUE)
a <- " thetao"
var <- str_replace_all(string = a, pattern = " ", replacement = "")



