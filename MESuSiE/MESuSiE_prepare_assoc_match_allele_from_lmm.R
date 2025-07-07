args <- commandArgs(trailingOnly = T)
library(tidyverse)

# gemma assoc is args[1];
# lmm output
# chr     rs      ps      n_miss  allele1 allele0 af      beta    se      logl_H1 l_remle p_wald
assoc <- read.table(args[1], header = T, as.is = T)

## allele list is args[2]; no header; first 3 columns (SNP,A1,A2)
allele <- read.table(args[2], as.is = T)
colnames(allele) <- c("SNP", "A1.tomatch", "A2.tomatch")

# plink .fam file is args[3]; only to get sample size N
fam <- read.table(args[3], as.is = T)
fam[fam[, 6] == -9, 6] <- NA
N <- sum(!is.na(fam[, 6]))

output <- args[4]

this_asso <- inner_join(assoc, allele, by = c("rs" = "SNP"))
# write.table(this_asso,"tep.file")
# assoc[,c("rs","beta","se")]
this_asso$Beta.tomatch <- ifelse(this_asso$allele1 == this_asso$A1.tomatch & this_asso$allele0 == this_asso$A2.tomatch,
  this_asso$beta, ifelse(this_asso$allele0 == this_asso$A1.tomatch & this_asso$allele1 == this_asso$A2.tomatch,
    -this_asso$beta, NA
  )
)
# colnames(summ)=c("SNP","Beta","Se")
this_asso$Z <- this_asso$Beta.tomatch / this_asso$se
this_asso$N <- N - this_asso$n_miss
this_asso <- this_asso %>% select(rs, Beta.tomatch, se, Z, N)
colnames(this_asso) <- c("SNP", "Beta", "Se", "Z", "N")

# rm NA
this_asso <- this_asso[!is.na(this_asso$Beta), ]
# keep SNP uniq
# this_asso=this_asso[!duplicated(this_asso$SNP),]

write.table(this_asso, output, row.names = F, col.names = T, quote = F)
