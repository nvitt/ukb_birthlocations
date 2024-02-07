### Principal Component Analysis ###

# Arguments passed from bash:
args = commandArgs(trailingOnly=TRUE)
scratchfolder = args[1]
outputfolder = args[2]
ukbsnplistfiles = args[3]
datafolder = args[4]
hapmap3file = args[5]

# Load packages bigsnpr and bigstatsr
library(bigsnpr)
library(stringr)
library(doParallel)

# Number of cores:
NCORES <- nb_cores()
print(NCORES)

### Obtain HapMap3 SNPs (to restrict analysis to these SNPs):
map_hapmap3 <- bigreadr::fread2(hapmap3file)
str(map_hapmap3)
names(map_hapmap3) <-
  c("chr",
    "rsid")

# Read BGEN and SAMPLE file and save as RDS - joint PCA and sibling sample:
if (!file.exists(paste0(scratchfolder,"genetic_files/PCA_sample_gwide.rds")))  {
  
  cl <- makeCluster(22)
  parallel::clusterExport(cl, c("map_hapmap3","ukbsnplistfiles"))
  list_snp_id <- parLapply(cl, 1:22, function(chr) {
    mfi <- paste0("/mnt/storage/private/mrcieu/data/ukbiobank/genetic/variants/arrays/imputed/released/2018-09-18/data/raw_downloaded/maf_info/ukb_mfi_chr", chr, "_v3.txt")
    infos_chr <- bigreadr::fread2(mfi, showProgress = FALSE)
    
    dosage_snp_list <- paste0(ukbsnplistfiles, chr, ".snplist")
    dosage_snps <- bigreadr::fread2(dosage_snp_list, header=FALSE, col.names = c("rsid"))
    
    infos_chr_dosage <-  dplyr::inner_join(infos_chr, dosage_snps,
                                           by = c("V2" = "rsid"))
    
    joined <- dplyr::inner_join(cbind(chr = chr, infos_chr_dosage), map_hapmap3[c("rsid")],
                                by = c("V2" = "rsid"))
    with(joined[!vctrs::vec_duplicate_detect(joined$V2), ],
         paste(chr, V3, V4, V5, sep = "_"))
  })
  stopCluster(cl)
  
  
  # PCA and sibling samples:
  sample <- bigreadr::fread2("/mnt/storage/private/mrcieu/data/ukbiobank/genetic/variants/arrays/imputed/released/2018-09-18/data/dosage_bgen/data.chr1-22_plink.sample")
  str(sample)
  sample <- sample[-1, ]
  
  pca_sample_ids <- bigreadr::fread2(paste0(datafolder,"pca_sample_IDs.txt"), header=FALSE, col.names = c("FID","IID"))
  sib_sample_ids <- bigreadr::fread2(paste0(datafolder,"sibling_pca_sample_IDs.txt"), header=FALSE, col.names = c("FID","IID"))
  
  pca_sib_sample <- sample[((sample$ID_2 %in% pca_sample_ids$IID)|(sample$ID_2 %in% sib_sample_ids$IID)),]
  pca_sib_sample$pca_sample<-as.integer(pca_sib_sample$ID_2 %in% pca_sample_ids$IID)
  pca_sib_sample$sibling_sample<-as.integer(pca_sib_sample$ID_2 %in% sib_sample_ids$IID)
  
  pca_sib_sample_rows <- match(pca_sib_sample$ID_2, sample$ID_2)
  str(pca_sib_sample_rows)
  
  rds <- bigsnpr::snp_readBGEN(
    bgenfiles   = glue::glue("/mnt/storage/private/mrcieu/data/ukbiobank/genetic/variants/arrays/imputed/released/2018-09-18/data/dosage_bgen/data.chr{chr}.bgen", chr = str_pad(1:22,2,pad="0")),
    bgi_dir = "/mnt/storage/private/mrcieu/data/ukbiobank/genetic/variants/arrays/imputed/released/2018-09-18/data/dosage_bgen/",
    list_snp_id = list_snp_id,
    backingfile = paste0(scratchfolder,"genetic_files/PCA_sample_gwide"),
    ind_row     = pca_sib_sample_rows,
    ncores      = NCORES
  )
  
  # add sample info to bigSNP object and re-save
  bigsnp_object <- readRDS(paste0(scratchfolder,"genetic_files/PCA_sample_gwide.rds"))
  str(pca_sib_sample)
  colnames(pca_sib_sample) <- c('family.ID','sample.ID','missing','sex','pca_sample','sibling_sample')
  str(pca_sib_sample)
  bigsnp_object$fam <- pca_sib_sample
  
  bigsnp_object$map <- dplyr::mutate(bigsnp_object$map, chromosome = as.integer(chromosome))
  
  saveRDS(bigsnp_object, paste0(scratchfolder,"genetic_files/PCA_sample_gwide.rds"))

}

# Attach the "bigSNP" object in R session
obj.bigSNP <- snp_attach(paste0(scratchfolder,"genetic_files/PCA_sample_gwide.rds"))
# See how the file looks like
str(obj.bigSNP, max.level = 2, strict.width = "cut")



# Get aliases for useful slots
map <- obj.bigSNP$map
G   <- obj.bigSNP$genotypes
CHR <- obj.bigSNP$map$chromosome
POS <- obj.bigSNP$map$physical.pos
FID   <- obj.bigSNP$fam$family.ID
IID   <- obj.bigSNP$fam$sample.ID
pca_rows   <- which(obj.bigSNP$fam$pca_sample==1)
sib_rows   <- which(obj.bigSNP$fam$sibling_sample==1)
rsid <- obj.bigSNP$map$marker.ID


# "Verification" there is no missing values
big_counts(G, ind.col = 1:12)


### PCA after pruning and removing long-range LD regions
# Remove SNPs with MAF<0.01:
maf<-snp_MAF(G, ind.row = pca_rows)
maf_exclude<-which(maf<0.01)
str(maf_exclude)

# Remove long-range LD regions:
lrldr<-snp_indLRLDR(CHR, POS)
str(lrldr)
lrldr_snps<-as.data.frame(cbind(rsid[lrldr],CHR[lrldr],POS[lrldr]))
colnames(lrldr_snps)<-c("rsid","chr","pos")
str(lrldr_snps)
write.csv(lrldr_snps, paste0(outputfolder,"pca_pruned_ldremoved_lrld_snps.csv"), row.names=FALSE, quote=FALSE)

# Pruning / clumping:
ind.keep_pruned_ldremoved <- snp_clumping(G, CHR, thr.r2 = 0.1, ind.row = pca_rows, ncores = NCORES,
                                          exclude=union(maf_exclude,lrldr))
str(ind.keep_pruned_ldremoved)

# Final set of SNPs used:
final_snps<-as.data.frame(cbind(rsid[ind.keep_pruned_ldremoved],CHR[ind.keep_pruned_ldremoved],POS[ind.keep_pruned_ldremoved]))
colnames(final_snps)<-c("rsid","chr","pos")
str(final_snps)

# PCA:
svd_pruned_ldremoved <- big_randomSVD(G, ind.row = pca_rows, snp_scaleBinom(), k=20, ncores = NCORES,
                                      ind.col = ind.keep_pruned_ldremoved)
str(svd_pruned_ldremoved)

# Details of PCA run:
details<-as.data.frame(cbind(svd_pruned_ldremoved$niter,svd_pruned_ldremoved$nops))
colnames(details)<-c("niter","nops")
str(details)
write.csv(details, paste0(outputfolder,"pca_pruned_ldremoved_details.csv"), row.names=FALSE, quote=FALSE)

# PCA singular values:
d<-as.data.frame(t(svd_pruned_ldremoved$d))
colnames(d)<-c(paste0("d_",1:20))
write.csv(d, paste0(outputfolder,"pca_pruned_ldremoved_singularvals.csv"), row.names=FALSE, quote=FALSE)

# PCA individual vectors:
ind_vectors<-as.data.frame(cbind(FID[pca_rows],IID[pca_rows],svd_pruned_ldremoved$u))
colnames(ind_vectors)<-c("FID","IID",paste0("u",1:20))
write.csv(ind_vectors, paste0(outputfolder,"pca_pruned_ldremoved_ind_vectors.csv"), row.names=FALSE, quote=FALSE)

# PCA SNP vectors:
snp_vectors<-as.data.frame(cbind(final_snps,svd_pruned_ldremoved$v,svd_pruned_ldremoved$center,svd_pruned_ldremoved$scale))
colnames(snp_vectors)<-c("rsid","chr","pos",paste0("vec",1:20),"center","scale")
write.csv(snp_vectors, paste0(outputfolder,"pca_pruned_ldremoved_snp_vectors.csv"), row.names=FALSE, quote=FALSE)

# PC scores:
scores_pruned_ldremoved <- predict(svd_pruned_ldremoved, G, ind.col = ind.keep_pruned_ldremoved) %>%
  cbind(FID,IID,.) %>%
  as.data.frame(.)
colnames(scores_pruned_ldremoved) <- c("FID","IID",paste0("pca_",1:20))
str(scores_pruned_ldremoved)
write.csv(scores_pruned_ldremoved, paste0(outputfolder,"pca_pruned_ldremoved_scores.csv"), row.names=FALSE, quote=FALSE)





### Automatic PCA procedure:
# Remove SNPs with MAF<0.01:
maf_keep<-which(maf>=0.01)
str(maf_keep)

# PCA:
svd_auto <- snp_autoSVD(G, ind.row = pca_rows, CHR, POS, thr.r2 = 0.1, k=20, ncores = NCORES, ind.col = maf_keep)
str(svd_auto)

# LD regions removed:
auto_lrldr<-as.data.frame(attributes(svd_auto)$lrldr)
str(auto_lrldr)
write.csv(auto_lrldr, paste0(outputfolder,"pca_auto_lrldr.csv"), row.names=FALSE, quote=FALSE)

# Final set of SNPs used:
auto_final_snps<-as.data.frame(cbind(rsid[attributes(svd_auto)$subset],CHR[attributes(svd_auto)$subset],POS[attributes(svd_auto)$subset]))
colnames(auto_final_snps)<-c("rsid","chr","pos")
str(auto_final_snps)

# Details of PCA run:
auto_details<-as.data.frame(cbind(svd_auto$niter,svd_auto$nops))
colnames(auto_details)<-c("niter","nops")
str(auto_details)
write.csv(auto_details, paste0(outputfolder,"pca_auto_details.csv"), row.names=FALSE, quote=FALSE)

# PCA singular values:
auto_d<-as.data.frame(t(svd_auto$d))
colnames(auto_d)<-c(paste0("d_",1:20))
write.csv(auto_d, paste0(outputfolder,"pca_auto_singularvals.csv"), row.names=FALSE, quote=FALSE)

# PCA individual vectors:
auto_ind_vectors<-as.data.frame(cbind(FID[pca_rows],IID[pca_rows],svd_auto$u))
colnames(auto_ind_vectors)<-c("FID","IID",paste0("u",1:20))
write.csv(auto_ind_vectors, paste0(outputfolder,"pca_auto_ind_vectors.csv"), row.names=FALSE, quote=FALSE)

# PCA SNP vectors:
auto_snp_vectors<-as.data.frame(cbind(auto_final_snps,svd_auto$v,svd_auto$center,svd_auto$scale))
colnames(auto_snp_vectors)<-c("rsid","chr","pos",paste0("vec",1:20),"center","scale")
write.csv(auto_snp_vectors, paste0(outputfolder,"pca_auto_snp_vectors.csv"), row.names=FALSE, quote=FALSE)



# PC scores:
scores_auto <- predict(svd_auto, G, ind.col = attributes(svd_auto)$subset) %>%
  cbind(FID,IID,.) %>%
  as.data.frame(.)
colnames(scores_auto) <- c("FID","IID",paste0("pca_",1:20))
str(scores_auto)
write.csv(scores_auto, paste0(outputfolder,"pca_auto_scores.csv"), row.names=FALSE, quote=FALSE)