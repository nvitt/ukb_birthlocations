setwd("C:\\Users\\pk20062\\Dropbox\\DONNI - UKB birth location accuracy")

# load packages
library(tidyverse)
library(spdep)

### Clear working environment:
rm(list = ls())

### Set seed for simulations:
set.seed(25021137)


### Load unique birth locations in UKB:
birth_locations <- st_read("gis_data\\eastings_northings_grid_uk.shp")

### Create neighbour and weighing matrix (based on 1.5km radius):
nb_locations <- dnearneigh(birth_locations, 0, 1500)
weights <- nb2listw(nb_locations, zero.policy = TRUE)
weights_spm <- as(nb2listw(nb_locations, zero.policy = TRUE), "CsparseMatrix")


### Calculate SAR weights matrix for different autocorrelation levels and then run simulation:
rho<-list(0,0.05,0.1,0.15,0.2,0.25,0.3,0.35,0.4,0.45,0.5,0.55,0.6,0.65,0.7,0.75,0.8,0.85,0.9,0.95,0.975)
simulations<-lapply(rho, function(x) {
  print(x)
  X<-matrix(rnorm(10*dim(weights_spm)[1]), ncol=10)
  sar_vector<-spatialreg::powerWeights(weights_spm, rho=x, order=1000, X=X)
  sim<-as.data.frame(as.matrix(sar_vector))
  colnames(sim)<-paste0("rho",x,"_",1:10)
  return(sim)
})
simulations_df<-bind_cols(simulations)

### Calculate Moran's I for simulated variables:
n<-length(simulations_df)
est_moran<-lapply(1:n, function(x){
  moran<-moran.test(simulations_df[,x], weights, zero.policy = TRUE, na.action = na.pass)
  var<-colnames(simulations_df[x])
  return(c(var,as.numeric(moran$estimate[1])))
})
est_moran_df<-as.data.frame(t(as.data.frame(est_moran)))
rownames(est_moran_df)<-1:n
colnames(est_moran_df)<-c("var","morans_i")



### Combine birth location information and simulated data:
birth_locations_with_sim <- cbind(birth_locations["easting"],birth_locations["northing"],simulations_df)
birth_locations_with_sim_df <- st_drop_geometry(birth_locations_with_sim)


### Export simulations:
bigreadr::fwrite2(birth_locations_with_sim_df, "gis_data\\simulations\\birth_location_grid_spatial_simulations.txt", col.names=TRUE, row.names=FALSE, quote=FALSE)

### Export spatial correlations for simulated data
bigreadr::fwrite2(est_moran_df, "gis_data\\simulations\\birth_location_grid_spatial_simulations_corr.txt", col.names=TRUE, row.names=FALSE, quote=FALSE)
