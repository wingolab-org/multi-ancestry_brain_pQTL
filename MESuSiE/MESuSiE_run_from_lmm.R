# setwd("/Users/yueliu/temp/temp1/Project_Diversity_pQTL/finemapping/MESuSIE/ENSG00000172803")
args <- commandArgs(trailingOnly = T)
library(tidyverse)
library(MESuSiE)

# args[1]="plink.race.list"
race <- read.table(args[1], as.is = T)$V1
if (length(race) < 2) {
  cat("fewer than two races, quit\n")
  q()
}

if (length(args) < 2) {
  output <- "MESuSiE_res"
} else {
  output <- args[2]
}

bim.suf <- ".mind005.match_allele.bim"
ld.suf <- ".mind005.match_allele.square.ld"
asso.suf <- ".lmm.assoc.txt.match_allele"


summ_stat_list <- list()
LD_list <- list()

# snp list is the snp list  in all files
# take first race as the beginning snp list
snp.list <- read.table(paste0(race[1], bim.suf), as.is = T)$V2
# add ld to LD_list, and add assoc to summ_stat_list
for (r in race) {
  this_bim <- read.table(paste0(r, bim.suf), as.is = T)$V2
  this_ld <- read.table(paste0(r, ld.suf), as.is = T)
  rownames(this_ld) <- this_bim
  colnames(this_ld) <- this_bim
  snp.list <- intersect(snp.list, this_bim)
  LD_list[[r]] <- this_ld

  this_asso <- read.table(paste0(r, asso.suf), header = T, as.is = T)
  rownames(this_asso) <- this_asso$SNP
  snp.list <- intersect(snp.list, this_asso$SNP)
  summ_stat_list[[r]] <- this_asso
}

# LD_list[["AA"]][1:5,1:5]
# summ_stat_list[["AA"]][1:5,]

# subset LD_list and summ_stat_list to snp.list
for (r in race) {
  LD_list[[r]] <- as.matrix(LD_list[[r]][snp.list, snp.list])
  summ_stat_list[[r]] <- summ_stat_list[[r]][snp.list, ]
}

MESuSiE_res <- meSuSie_core(LD_list, summ_stat_list, L = 10)
# MESuSiE_res.NHW_AA=meSuSie_core(LD_list[c("AA","NHW")],
#                                summ_stat_list[c("AA","NHW")],L=10)


save(LD_list, summ_stat_list, race, snp.list, MESuSiE_res, file = paste0(output, ".RDat"))
