MYDIR="/fs/nara-scratch/qwang37/brain_data"

ds1=`ls -l $MYDIR | egrep '^d' | awk '$9 ~ /^d/ {print $9}'`
for d1 in $ds1; do
  d=$MYDIR'/'$d1
  ds2=`ls -l $d | egrep '^d' | awk '$9 ~ /^S/ {print $9}'`
  for d2 in $ds2; do
    dd=$d'/'$d2
    echo 'processing '$dd
    #mkdir $dd'/atlas'
    #mkdir $dd'/atlas_aal_90'
    if [ ! -d "$dd/atlas_MNI" ]; then
	mkdir $dd'/'atlas_MNI
    fi
    ref='/fs/nara-scratch/qwang37/brain_data/Atlases/aal_90_2mm_correct.nii.gz'
    inputlist=`ls $dd'/'atlas_local`
    for input in $inputlist; do
	inputfull=$dd'/'atlas_local'/'$input
	out=$dd'/'atlas_MNI'/'$input
	mat=$dd'/dti.bedpostX/xfms/coef_diff2standard'
	applywarp -i $inputfull -r $ref -o $out -w $mat
    done
  done
done


#applywarp -i /chimerahomes/qwang37/fsl/fsl/data/atlases/JHU/JHU-ICBM-labels-2mm -r /fs/nara-scratch/qwang37/brain_data/d01/S0229/dti.bedpostX/nodif_brain -o /fs/nara-scratch/qwang37/brain_data/d01/S0229/mask_white_matter -w /fs/nara-scratch/qwang37/brain_data/d01/S0229/dti.bedpostX/xfms/coef_standard2diff
