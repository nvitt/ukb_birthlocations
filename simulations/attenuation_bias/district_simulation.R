setwd("C:\\Users\\pk20062\\Dropbox\\DONNI - UKB birth location accuracy")

# load packages
library(tidyverse)
library(sf)
library(geostan)
library(spdep)

### Clear working environment:
rm(list = ls())

### Set seed for simulations:
set.seed(20022213)


### Load unique birth locations in UKB:
districts <- st_read("gis_data\\shp\\1951_Districts_GB.shp")


### Fix a few errors for Scottish districts (otherwise we have duplicate district IDs):
# Find duplicate district IDs:
n_occur<-data.frame(table(districts$G_UNIT))
table(n_occur$Freq)
districts[districts$G_UNIT %in% n_occur$Var1[n_occur$Freq > 1],]

# LESLIE GREEN is wrongly labelled FALKLAND:
districts[1630,]
districts[1630,"G_UNIT"]<-10360730
districts[1630,"G_NAME"]<-"LESLIE GREEN"
districts[1630,]

# GALASHIELS is wrongly labelled NORTH SELKIRK:
districts[1504,]
districts[1504,"G_UNIT"]<-10359673
districts[1504,"G_NAME"]<-"GALASHIELS"
districts[1504,]

# NEW GALLOWAY is wrongly labelled GLENKENS:
districts[1483,]
districts[1483,"G_UNIT"]<-10361242
districts[1483,"G_NAME"]<-"NEW GALLOWAY"
districts[1483,]

# PORTSOY is wrongly labelled PARISOY:
districts[1530,]
districts[1530,"G_UNIT"]<-10361655
districts[1530,"G_NAME"]<-"PORTSOY"
districts[1530,]

# MILLPORT is wrongly labelled MILPORT:
districts[1587,]
districts[1587,"G_UNIT"]<-10361060
districts[1587,"G_NAME"]<-"MILLPORT"
districts[1587,]

# district ID is missing for STORNAWAY:
districts[1509,]
districts[1509,"G_UNIT"]<-10362131
districts[1509,]

# district ID is missing for TAIN Burgh:
districts[1513,]
districts[1513,"G_UNIT"]<-10362192
districts[1513,]

# district ID is missing for ANSTRUTHER DoC:
districts[1730,]
districts[1730,"G_UNIT"]<-10285071
districts[1730,]

# district ID is missing for QUEENSFERRY DoC:
districts[1814,]
districts[1814,"G_UNIT"]<-12838748
districts[1814,]

# Part of Wigtown Burgh is wrongly labelled Machars (merge this with existing part of Wigtown)
districts[1475,]
plot(st_geometry(districts[1475,]))
districts[1474,]
plot(st_geometry(districts[1474,]))

districts_new<-districts[-1475,]
districts_new[1474,]$geometry<-st_union(districts[1474,]$geometry,districts[1475,]$geometry)
plot(st_geometry(districts_new[1474,]))

# Check again for duplicate district IDs:
n_occur_new<-data.frame(table(districts_new$G_UNIT))
table(n_occur_new$Freq)









# Generate initial weighting matrix:
w_init <- shape2mat(districts_new, "W")
has_neighbours<-(round(Matrix::rowSums(w_init), 10)== 1)

# Omit districts without direct neighbours, and create weighting matrix for these:
districts_connected <- districts_new[has_neighbours,]
w <- shape2mat(districts_connected, "W")

# Simulate data for different values of rho (spatial autocorrelation parameter):
rho<-list(0,0.05,0.1,0.15,0.2,0.25,0.3,0.35,0.4,0.45,0.5,0.55,0.6,0.65,0.7,0.75,0.8,0.85,0.9,0.95,0.975,0.999)
simulations<-lapply(rho, function(x) {
  sim <- sim_sar(m=10, w = w, rho = x)
  sim <- data.frame(t(sim))
  colnames(sim)<-paste0("rho",x,"_",1:10)
  return(sim)
  })
simulations_df<-bind_cols(simulations)


#est_rho<-lapply(1:10, function(x){
#  rho<-aple(sim[,x], w)
#  return(rho)
#})

# Calculate Moran's I for simulated data:
n<-length(simulations_df)
est_moran<-lapply(1:n, function(x){
  moran<-moran.test(simulations_df[,x], mat2listw(w) )
  var<-colnames(simulations_df[x])
  return(c(var,as.numeric(moran$estimate[1])))
})
est_moran_df<-as.data.frame(t(as.data.frame(est_moran)))
rownames(est_moran_df)<-1:n
colnames(est_moran_df)<-c("var","morans_i")


# Create dataframe with district IDs and simulated data (without spatial geometry data):
districts_with_sim <- cbind(districts_connected["G_UNIT"],simulations_df)

plot(districts_with_sim["rho0_1"])
plot(districts_with_sim["rho0.5_1"])
plot(districts_with_sim["rho0.999_1"])

districts_with_sim_df <- st_drop_geometry(districts_with_sim)


### Export simulations:
bigreadr::fwrite2(districts_with_sim_df, "gis_data\\simulations\\district_spatial_simulations.txt", col.names=TRUE, row.names=FALSE, quote=FALSE)

### Export spatial correlations for simulated data
bigreadr::fwrite2(est_moran_df, "gis_data\\simulations\\district_spatial_simulations_corr.txt", col.names=TRUE, row.names=FALSE, quote=FALSE)
