#!/bin/sh
array=([1]=ESS [2]=PERF [3]=PERF_STAGE [4]=STD)
for i in ${array[@]}
do
cd /data/backup/rsync/CLM_$i/
array1=(`ls`)
for j in ${array1[@]}
do
str=`cat $j/$j.*.log | grep 'rsync completed normally'`
const="rsync completed normally"
if [[ "$str"=="$const" ]];
then
echo "Good!"
else
echo "Not good!"
fi
done
kol=`ls -f . | wc -l`
echo $kol
done
date

