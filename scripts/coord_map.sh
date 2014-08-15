#!/bin/bash
cd /fs/nara-scratch/qwang37/brain_data/
d1s=$1
for d1 in $d1s; do
    d2s=`ls $d1 -l | egrep '^d' | awk '$9 ~ /^S/ {print $9}'`
    for d2 in $d2s; do
	dw=$d1/$d2
	echo "processing $dw"
	img2imgcoord -src $dw/dti.bedpostX/nodif_brain.nii.gz -dest /fs/nara-scratch/qwang37/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz -warp $dw/dti.bedpostX/xfms/coef_diff2standard.nii.gz $dw/track_aal_90_0/coords_pruned -vox | sed '$d' > $dw/track_aal_90_0/coords_mapped
    done
done
	