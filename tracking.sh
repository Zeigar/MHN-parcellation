MYDIR="/fs/nara-scratch/qwang37/brain_data"
ds1=`ls -l $MYDIR | egrep '^d' | awk '{print $9}'`
num_sim=$((8))
curr_sim=$((0))
for d1 in $ds1; do
  d=$MYDIR'/'$d1
  ds2=`ls -l $d | egrep '^d' | awk '{print $9}'`
  for d2 in $ds2; do
    dd=$d'/'$d2
    echo 'processing '$dd
    rm -rf $dd'/track'
    mkdir -p $dd'/track'
    grey=$dd'/mask_grey_matter'
    white=$dd'/mask_white_matter'
    if [ $curr_sim -lt $num_sim ]; then
      curr_sim=$((curr_sim+1))
      probtrackx2  -x $white  -l --onewaycondition --omatrix3 --target3=$grey --lrtarget3=$grey -c 0.2 -S 2000 --steplength=0.5 -P 500 --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 --forcedir --opd -s $dd'/dti.bedpostX/merged' -m $dd'/dti.bedpostX/nodif_brain_mask'  --dir=$dd'/track' &
    else
      curr_sim=$((0))
      probtrackx2  -x $white  -l --onewaycondition --omatrix3 --target3=$grey --lrtarget3=$grey -c 0.2 -S 2000 --steplength=0.5 -P 500 --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 --forcedir --opd -s $dd'/dti.bedpostX/merged' -m $dd'/dti.bedpostX/nodif_brain_mask'  --dir=$dd'/track'
    fi
  done
done
