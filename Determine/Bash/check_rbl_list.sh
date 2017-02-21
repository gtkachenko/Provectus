#!/usr/bin/env bash
user=$(whoami)
cd /home/$user/Bash
RBL="rbl_list.txt"

W=$( echo ${1} | cut -d. -f1 )
X=$( echo ${1} | cut -d. -f2 )
Y=$( echo ${1} | cut -d. -f3 )
Z=$( echo ${1} | cut -d. -f4 )

STATUS=0

for i in $(cat $RBL)
do
    RESULT=$( host -t a $Z.$Y.$X.$W.$i 2>&1 )
    if [ $? -eq 0 ]
    then
        echo “The IP ADDRESS ${1} is listed at $i:\n$RESULT” ## DEBUG
        let "STATUS += 1"
    fi
    echo $RESULT ## DEBUG
done

if [ $STATUS -lt 1 ]
then
    echo 0
else
    echo $STATUS
fi