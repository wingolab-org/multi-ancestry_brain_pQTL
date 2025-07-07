dirlist=$1

pwd=$(pwd)
for f in $(less $dirlist); do
  cd $f
  Rscript ~/bin/MESuSiE_run_from_lmm.R plink.race.list > MESuSiE_run.log
  cd $pwd
done
