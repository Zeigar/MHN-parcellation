#!/bin/bash
cd /fs/nara-scratch/qwang37/brain_data
d1s=`ls -l | grep '^d' | awk '$9 ~ /^data_/ {print $9}'`
for d1 in $d1s; do
    d2s=`ls $d1 -l | grep '^d' | awk '$9 ~ /^S[0-9][0-9][0-9][0-9]/ {print $9}'`
    for d2 in $d2s; do
	echo processing $d1/$d2
        #fnirtfileutils --in=$d1/$d2/dti.bedpostX/xfms/coef_standard2diff --ref=$d1/$d2/dti.bedpostX/nodif_brain --out=$d1/$d2/field_standard2diff --withaff
	fnirtfileutils --in=$d1/$d2/dti.bedpostX/xfms/coef_diff2standard --ref=/fs/nara-scratch/qwang37/fsl/data/standard/MNI152_T1_2mm_brain --out=$d1/$d2/dti.bedpostX/xfms/field_diff2standard --withaff
    done
    #d2s=`ls $d1/processed -l | grep '^d' | awk '$9 ~ /^S/ {print $9}'`
    #for d2 in $d2s; do
	#echo processing $d1/processed/$d2
	#fnirtfileutils --in=$d1/processed/$d2/dti.bedpostX/xfms/coef_standard2diff --ref=$d1/processed/$d2/dti.bedpostX/nodif_brain --out=$d1/processed/$d2/field_standard2diff --withaff
	#mv $d1/processed/$d2/field_standard2diff.nii.gz $d1/processed/$d2/dti.bedpostX/xfms/
    #done
done