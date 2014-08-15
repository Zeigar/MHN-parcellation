#!/bin/bash
if [ "$1" == "" -o "$2" == "" -o "$3" == "" ]; then
    echo "Usage: ./del_something.sh -d(dir)/-S(subject) content rootdir"
    exit
fi

ds=`ls $3 -l | egrep '^d' | awk '$9 ~ /^d/ {print $9}'`
echo $1
if [ "$1" == "-d" ]; then
    for d in $ds; do
	echo "processing $3/$d"
	rmdir $3/$d/$2  # take care!!!
    done
elif [ "$1" == "-S" ]; then
    for d in $ds; do
	d1=`ls $3/$d -l | egrep '^d' | awk '$9 ~ /^S/ {print $9}'`
	for dd in $d1; do
	    echo "processing $3/$d/$dd"
	    rm -rf $3/$d/$dd/$2  # take care!!!
	done
    done
fi
    
