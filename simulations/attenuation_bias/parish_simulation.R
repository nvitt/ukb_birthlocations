setwd("C:\\Users\\pk20062\\Dropbox\\DONNI - UKB birth location accuracy")

# load packages
library(tidyverse)
library(sf)
library(geostan)
library(spdep)

### Clear working environment:
rm(list = ls())

### Set seed for simulations:
set.seed(20022222)


### Load unique birth locations in UKB:
parishes <- st_read("gis_data\\shp\\1951_parishes_GB.shp")

# Generate initial weighting matrix:
w_init <- shape2mat(parishes, "W")
has_neighbours<-(round(Matrix::rowSums(w_init), 10)== 1)

# Omit parishes without direct neighbours, and create weighting matrix for these:
parishes_connected <- parishes[has_neighbours,]
w <- shape2mat(parishes_connected, "W")

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
parishes_with_sim <- cbind(parishes_connected["G_UNIT"],simulations_df)

plot(parishes_with_sim["rho0_1"])
plot(parishes_with_sim["rho0.5_1"])
plot(parishes_with_sim["rho0.999_1"])

parishes_with_sim_df <- st_drop_geometry(parishes_with_sim)


### Export simulations:
bigreadr::fwrite2(parishes_with_sim_df, "gis_data\\simulations\\parish_spatial_simulations.txt", col.names=TRUE, row.names=FALSE, quote=FALSE)

### Export spatial correlations for simulated data
bigreadr::fwrite2(est_moran_df, "gis_data\\simulations\\parish_spatial_simulations_corr.txt", col.names=TRUE, row.names=FALSE, quote=FALSE)
