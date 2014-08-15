rootdir=`pwd`
dd=`ls -l $d | egrep '^d' | awk '{print $9}'`

for d in $dd; do
  if [ $(echo "$d" | grep -E "^d") ]; then
    ds2=`ls -l $d | egrep '^d' | awk '{print $9}'`

    for d2 in $ds2; do
      if [ $(echo "$d2" | grep -E "^S") ]; then
	echo 'processing '$rootdir'/'$d'/'$d2

	grey=$d'/'$d2'/mask_grey_matter_aal_90'
	white=$d'/'$d2'/mask_white_matter'
	num_sim=4
	curr_sim=0
	while [ $curr_sim -lt $num_sim ]
	do
	  rm -rf $d'/'$d2'/track_aal_90_'$curr_sim
	  mkdir -p $d'/'$d2'/track_aal_90_'$curr_sim
	  probtrackx2  -x $white  -l --onewaycondition --omatrix3 --target3=$grey --lrtarget3=$grey -c 0.2 -S 2000 --steplength=0.5 -P 50 --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 --forcedir --opd -s $d'/'$d2'/dti.bedpostX/merged' -m $d'/'$d2'/dti.bedpostX/nodif_brain_mask'  --dir=$d'/'$d2'/track_aal_90_'$curr_sim --rseed=$RANDOM &
	  let curr_sim+=1
	done
	wait
    
	break
      fi
    done
  fi
done
#wait
