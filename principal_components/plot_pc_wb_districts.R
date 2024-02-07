setwd("C:\\Users\\pk20062\\Dropbox\\DONNI - UKB birth location accuracy")

# load packages
library(tidyverse)
library(sf)
library(geostan)
library(spdep)
library(ggplot2)
library(colorspace)

### Clear working environment:
rm(list = ls())


### Load unique birth locations in UKB:
districts <- st_read("gis_data\\shp\\1951_Districts_GB.shp")



### Load district-level average principal components:
district_pcs <- bigreadr::fread2("//rdsfcifs.acrc.bris.ac.uk/GeneEnvironment_Interactions/UKB/GeographicID/Projects/NV_Papers/Birth locations/csv/principal_components_by_district.csv")



### Merge:
districts_with_pcs <- merge(districts,district_pcs,by.x="G_UNIT",by.y="gid",all.X=TRUE,all.y=FALSE)
colnames(districts_with_pcs)[54:73]<-c("PC1","PC2","PC3","PC4","PC5","PC6","PC7","PC8","PC9","PC10","PC11","PC12","PC13","PC14","PC15","PC16","PC17","PC18","PC19","PC20")



### Plot:
pcs <- districts_with_pcs %>% select(PC1,PC2,PC3,PC4,PC5,PC6,geometry) %>% gather(VAR, PC, -geometry)
pcs$VAR<-sub("PC","PC ",pcs$VAR)
pcs$VAR_f<-factor(pcs$VAR, levels = c("PC 1","PC 2","PC 3","PC 4","PC 5","PC 6"))

png(file="output\\graphs\\principal_components\\principal_component_maps_wb.png",width=2400, height=2400, pointsize=70)
ggplot() + 
  geom_sf(data = pcs, aes(fill = PC), color = NA) + 
  facet_wrap(vars(VAR_f), ncol = 3) +
  coord_sf(datum = NA) +
  theme_minimal(base_size=50) +
  theme(strip.text = element_text(size = 50,face ="bold"), legend.position="bottom", legend.title=element_blank()) +
  scale_fill_continuous_sequential(palette = "Reds", l1 = 0, l2 = 95, p1 = 1)
dev.off()

