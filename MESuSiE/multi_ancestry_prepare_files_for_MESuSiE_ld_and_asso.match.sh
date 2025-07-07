dirlist=$1

pwd=$(pwd)
for f in $(less $dirlist); do
  cd $f

  #double check missingness; require mind 0.05
  for r in $(less plink.race.list); do
    plink --bfile $r --mind 0.05 --geno 0.05 --out $r.mind005 --make-bed
  done

  #get match alleles
  #remove ambiguous alleles (A/T and G/C)
  awk '{if ( ! ( ($5 == "A" && $6 == "T") || ($5 == "T" && $6 == "A") || ($5 == "G" && $6 == "C") || ($5 == "C" && $6 == "G") ) ) { print  $2,$5,$6}}' bim_for_match_alleles > match.alleles.A1_A2
  awk '{print $1,$2}' match.alleles.A1_A2 > match.alleles

  #new plink files that match alleles
  for r in $(less plink.race.list); do
    plink --bfile $r.mind005 --extract match.alleles --reference-allele match.alleles --make-bed --out $r.mind005.match_allele
  done

  #ld matrix
  for r in $(less plink.race.list); do
    plink --bfile $r.mind005.match_allele --r square --out $r.mind005.match_allele.square --reference-allele match.alleles
  done

  #match allele to lmm assoc
  for r in $(less plink.race.list); do
    Rscript ~/bin/MESuSiE_prepare_assoc_match_allele_from_lmm.R $r.lmm.assoc.txt match.alleles.A1_A2 $r.fam $r.lmm.assoc.txt.match_allele
  done

  cd $pwd
done
