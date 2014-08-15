if [ $1 == "" ]; then
  echo 'Usage: ./tracking_aal_90.sh rootdir'
fi

rootdir=$1
ds2=`ls -l $d | egrep '^d' | awk '{print $9}'`
#curr_process=0
for d2 in $ds2; do
  echo 'processing '$rootdir'/'$d2

  grey=$d2'/mask_grey_matter_aal_90'
  white=$d2'/mask_white_matter'
  num_sim=1
  curr_sim=0
  while [ $curr_sim -lt $num_sim ]
  do
    rm -rf $d2'/track_aal_90_'$curr_sim
    mkdir -p $d2'/track_aal_90_'$curr_sim
    probtrackx2  -x $white  -l --onewaycondition --omatrix3 --target3=$grey --lrtarget3=$grey -c 0.2 -S 2000 --steplength=0.5 -P 50 --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 --forcedir --opd -s $d2'/dti.bedpostX/merged' -m $d2'/dti.bedpostX/nodif_brain_mask'  --dir=$d2'/track_aal_90_'$curr_sim --rseed=$RANDOM &
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
