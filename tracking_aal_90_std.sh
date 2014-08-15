if [ $1 == "" ]; then
  echo 'Usage: ./tracking_aal_90_std.sh rootdir'
fi

rootdir=$1
ds2=`ls -l $rootdir | egrep '^d' | awk '$9 ~ /S[0-9][0-9][0-9][0-9]/ {print $9}'`
#curr_process=0
for d2 in $ds2; do
  echo 'processing '$rootdir'/'$d2

  grey=/fs/nara-scratch/qwang37/brain_data/Atlases/aal_90_2mm_correct
  white=/fs/nara-scratch/qwang37/fsl/data/atlases/JHU/JHU-ICBM-labels-2mm
  num_sim=1
  curr_sim=0

  while [ $curr_sim -lt $num_sim ]
  do
    rm -rf $rootdir/$d2'/track_aal_90_std_'$curr_sim
    mkdir -p $rootdir/$d2'/track_aal_90_std_'$curr_sim
    probtrackx2  -x $white  -l --onewaycondition --omatrix3 --target3=$grey --lrtarget3=$grey -c 0.2 -S 2000 --steplength=0.5 -P 50 --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 --forcedir --opd -s $rootdir/$d2'/dti.bedpostX/merged' -m $rootdir/$d2'/dti.bedpostX/nodif_brain_mask'  --dir=$rootdir/$d2'/track_aal_90_std_'$curr_sim --rseed=$RANDOM --xfm=$rootdir/$d2/dti.bedpostX/xfms/coef_standard2diff --invxfm=$rootdir/$d2/dti.bedpostX/xfms/coef_diff2standard &
    #rseed=$RANDOM
    #echo process $curr_sim$' the random seed is '$rseed &
    let curr_sim+=1
#    let curr_process+=1
  done
  wait
#  if [ $curr_process -eq 16 ]; then
#    wait
#    let curr_process=0
#  fi
done
#wait
