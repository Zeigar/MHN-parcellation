MYDIR="/fs/nara-scratch/qwang37/brain_data"
ds1=`ls -l $MYDIR | egrep '^d' | awk '{print $9}'`
for d1 in $ds1; do
  d=$MYDIR'/'$d1
  ds2=`ls -l $d | egrep '^d' | awk '{print $9}'`
  for d2 in $ds2; do
    dt=$d'/'$d2$'/track_aal_90'
    rm -rf $dt
    echo 'deleted '$dt
  done
done

