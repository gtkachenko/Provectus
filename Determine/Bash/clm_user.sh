#!/bin/bash
customer=$1
function usage ()  {
        echo "Usage: clm-user.sh please specify custname"
}
	if [[ -z $customer ]]
	then
		usage
		exit 1
	fi
user_clm=$(ps aux | grep $customer | grep -v grep | grep -v ec2-user | awk '{print $1}')

 if [[ "$user_clm" == "stdstg" ]] ||  [[ "$user_clm" == "stdsvc" ]] || [[ "$user_clm" == "perfstg" ]] || [[ "$user_clm" == "perfsvc" ]] || [[ "$user_clm" == "esssvc" ]] || [[ "$user_clm" == "user" ]] 
 then
	sudo -i -u $user_clm
 else
	ps aux | grep $customer
	read number
        sudo kill -9 $number
	sudo -i -u $(ps aux | grep $customer | grep -v grep | grep -v ec2-user | awk '{print $1}')
 fi

