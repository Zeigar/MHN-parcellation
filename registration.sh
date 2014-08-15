MYDIR="/fs/nara-scratch/qwang37/brain_data"
#input='/fs/nara-scratch/qwang37/fsl/data/atlases/JHU/JHU-ICBM-labels-2mm'
#input='/fs/nara-scratch/qwang37/fsl/data/atlases/MNI/MNI-maxprob-thr50-2mm'
#input='/fs/nara-scratch/qwang37/fsl/data/atlases/HarvardOxford/HarvardOxford-cort-maxprob-thr25-2mm'
#input='./aal_90_2mm_correct.nii.gz'
input='/fs/nara-scratch/qwang37/fsl/data/atlases/Striatum/striatum-structural-2mm.nii.gz'
ds1=`ls -l $MYDIR | egrep '^d' | awk '$9 ~ /^d/ { print $9 }'`
for d1 in $ds1; do
  d=$MYDIR'/'$d1
  ds2=`ls -l $d | egrep '^d' | awk '$9 ~ /^S/ { print $9 }'`
  for d2 in $ds2; do
    #if [ "$d2" == "S0282" ]; then
    dd=$d'/'$d2
    echo 'processing '$dd
    ref=$dd'/dti.bedpostX/nodif_brain'
    #out=$dd'/mask_white_matter'
    #out=$dd'/mask_grey_matter_aal_90'
    out=$dd'/mask_striatum'
    mat=$dd'/dti.bedpostX/xfms/coef_standard2diff'
    applywarp -i $input -r $ref -o $out -w $mat
    #fi
  done
done


#applywarp -i /chimerahomes/qwang37/fsl/fsl/data/atlases/JHU/JHU-ICBM-labels-2mm -r /fs/nara-scratch/qwang37/brain_data/d01/S0229/dti.bedpostX/nodif_brain -o /fs/nara-scratch/qwang37/brain_data/d01/S0229/mask_white_matter -w /fs/nara-scratch/qwang37/brain_data/d01/S0229/dti.bedpostX/xfms/coef_standard2diff
