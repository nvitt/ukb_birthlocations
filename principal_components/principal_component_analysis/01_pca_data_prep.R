#~~~~~~~~~~~~~~~~~~~~~~~~#
#File Preparation for PCA#
#~~~~~~~~~~~~~~~~~~~~~~~~#

# Arguments passed from bash:
args = commandArgs(trailingOnly=TRUE)
datafolder = args[1]

library(dplyr)

#Import sample definition with IEU identifiers: 
ieusample_unrelated<-read.table(paste0(datafolder,"pca_data.csv"), header=T, sep=",")



#Exclusions

#1. Standard Exclusions
#Individuals to exclude, N=1812
#individuals mismatched in their genetic sex compared to their reported sex, N=378
#individuals with sex chromosome karyotypes putatively different from XX or XY, N=652
#individuals that are outliers in heterozygosity and missing rates, N=968
#duplicates removed
recommendexclusion<-read.table("/mnt/storage/private/mrcieu/data/ukbiobank/genetic/variants/arrays/imputed/released/2018-09-18/data/derived/standard_exclusions/data.combined_recommended.qctools.txt", header=F)
colnames(recommendexclusion)[colnames(recommendexclusion)=="V1"] <- "IID"
recommendexclusion$standardexc<-1
ieusample1<-merge(ieusample_unrelated, recommendexclusion, by="IID", all.x=TRUE)

#2. Ancestry restrictions
#non-white british N=78,674
nonwhitebritish<-read.table("/mnt/storage/private/mrcieu/data/ukbiobank/genetic/variants/arrays/imputed/released/2018-09-18/data/derived/ancestry/data.non_white_british.qctools.txt", header=F)
colnames(nonwhitebritish)[colnames(nonwhitebritish)=="V1"] <- "IID"
nonwhitebritish$nonWB<-1
ieusample1<-merge(ieusample1, nonwhitebritish, by="IID", all.x=TRUE)

#3. Relatedness (IEU specification)
highlyrelated<-read.table("/mnt/storage/private/mrcieu/data/ukbiobank/genetic/variants/arrays/imputed/released/2018-09-18/data/derived/related/relateds_exclusions/data.highly_relateds.qctools.txt", header=F)
colnames(highlyrelated)[colnames(highlyrelated)=="V1"] <- "IID"
highlyrelated$highlyrelated<-1
ieusample1<-merge(ieusample1, highlyrelated, by="IID", all.x=TRUE)
minimalrelated<-read.table("/mnt/storage/private/mrcieu/data/ukbiobank/genetic/variants/arrays/imputed/released/2018-09-18/data/derived/related/relateds_exclusions/data.minimal_relateds.qctools.txt", header=F)
colnames(minimalrelated)[colnames(minimalrelated)=="V1"] <- "IID"
minimalrelated$minimalrel<-1
ieusample1<-merge(ieusample1, minimalrelated, by="IID", all.x=TRUE)

#4. Not included in IEU genotype data:
ieu_genotype_sample<-read.table("/mnt/storage/private/mrcieu/data/ukbiobank/genetic/variants/arrays/imputed/released/2018-09-18/data/dosage_bgen/data.chr1-22_plink.sample", header=T)
colnames(ieu_genotype_sample)[colnames(ieu_genotype_sample)=="ID_1"] <- "IID"
ieu_genotype_sample$ieu_genotype_sample<-1
ieu_genotype_sample<-ieu_genotype_sample[,c("IID", "ieu_genotype_sample")]
ieusample1<-merge(ieusample1, ieu_genotype_sample, by="IID", all.x=TRUE)

ieusample1$pca_sample_qc<-ifelse(is.na(ieusample1$standardexc)&is.na(ieusample1$nonWB)&is.na(ieusample1$highlyrelated)&is.na(ieusample1$minimalrel)&ieusample1$ieu_genotype_sample==1, ieusample1$pca_sample, -999)
#1 = include in PCA, -888=related (NORFACE specification), -999 = exclusions
table(ieusample1$pca_sample_qc)


#combine with plink covariate file (FID, IID, sex, chip)
plinkcov<-read.table("/mnt/storage/private/mrcieu/data/ukbiobank/genetic/variants/arrays/imputed/released/2018-09-18/data/derived/standard_covariates/data.covariates.plink.txt", header=F)
colnames(plinkcov)[colnames(plinkcov)=="V1"] <- "FID"
colnames(plinkcov)[colnames(plinkcov)=="V2"] <- "IID"
colnames(plinkcov)[colnames(plinkcov)=="V3"] <- "sex"
colnames(plinkcov)[colnames(plinkcov)=="V4"] <- "chip"

#Use the plinkcov file as the reference file - all the IDs in this file should match the IDs we have in our end file
ieusample<-merge(ieusample1, plinkcov, by="IID", all.y=TRUE)


# PCA sample:
pca_sample<-ieusample[which(ieusample$pca_sample_qc==1),]

pca<-pca_sample[,c("IID", "FID", "sex", "chip")]
write.csv(pca, paste0(datafolder,"pca_sample.csv"))
pca_IDs<-pca_sample[,c("IID", "FID")]
colnames(pca_IDs) <- NULL
write.table(pca_IDs, paste0(datafolder,"pca_sample_IDs.txt"),sep="\t",row.names=FALSE, quote=FALSE)


# Sibling sample:
ieusample$sibling_sample_qc<-ifelse(is.na(ieusample$standardexc)&is.na(ieusample$nonWB)&ieusample$ieu_genotype_sample==1, ieusample$sibling_sample, -999)
#1 = include in PCA sibling sample, 0 = not in sibling sample, -999 = exclusions
table(ieusample$sibling_sample_qc)
sibling_sample<-ieusample[which(ieusample$sibling_sample_qc==1),]

sibling_pca<-sibling_sample[,c("IID", "FID", "sex", "chip")]
write.csv(sibling_pca, paste0(datafolder,"sibling_pca_sample.csv"))
sibling_pca_IDs<-sibling_sample[,c("IID", "FID")]
colnames(sibling_pca_IDs) <- NULL
write.table(sibling_pca_IDs, paste0(datafolder,"sibling_pca_sample_IDs.txt"),sep="\t",row.names=FALSE, quote=FALSE)
