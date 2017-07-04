#!/bin/bash
os_user='ec2-user'
host='10.100.1.44'
key='/home/gtkachenko/.ssh/Storage.pem'
tmstmp=$(date +%m-%d-%Y-%H-%M-%S)

function colecho {
	case "$1" in
      INFO ) echo -en "\e[96m" ;;
      WARN ) echo -en "\e[33m" ;;
      FAIL ) echo -en "\e[31m" ;;
    esac
    echo $2
    echo -en "\e[0m"
}

colecho INFO "Please specify file name with environments that need remove and press Enter: "
read filename

if test -f $filename; then
	colecho INFO "Specified file is present continue "
else
	colecho FAIL "Specified file was not found please try again"
	exit 1
fi


colecho INFO "Change data from file in correct format "
for i in $(cat list | awk -F "." '{print $1}'); do echo $i | tr A-Z a-z; done >> list_format

colecho WARN "Removing unformated file with environments"
#rm -f $filename


colecho INFO "Make backup before removing customers and workers properies"
folder_before=$(ssh -t -t ${os_user}@${host} -i ${key} " stat /opt/auto/backups")
files_before=$(ssh -t -t ${os_user}@${host} -i ${key} " ls -l /opt/auto/backups | wc -l")
ssh -t -t ${os_user}@${host} -i ${key} " cp /opt/auto/new_customers.txt /opt/auto/backups/new_customers.txt.$tmstmp"
ssh -t -t ${os_user}@${host} -i ${key} " cp /opt/auto/tomcat.workers /opt/auto/backups/tomcat.workers.$tmstmp"

colecho INFO "Checking backup files "
folder_after=$(ssh -t -t ${os_user}@${host} -i ${key} " stat /opt/auto/backups")
files_after=$(ssh -t -t ${os_user}@${host} -i ${key} " ls -l /opt/auto/backups | wc -l")
if  [ "${folder_before}" == "${folder_after}" ] && [ "${files_before}" == "${files_after}" ] ; then
	colecho FAIL "Something went wrong backup was not done"
	exit 1
else
	colecho INFO "Backup done successfully"
fi

colecho INFO "Downloading configurations files on localhost "
scp -i ${key} ${os_user}@${host}:/opt/auto/new_customers.txt ./
scp -i ${key} ${os_user}@${host}:/opt/auto/tomcat.workers ./


colecho INFO "Starting remove propertirs for current environments from downloaded files"
customer_before=$(cat new_customers.txt | wc -l)
workers_before=$(cat tomcat.workers | wc -l)

colecho INFO "Removing name environments name from customer list"
const=1
for customer in $(cat list_format); 
do check_name=$(cat new_customers.txt | grep $customer | wc -l);
 if [ ${check_name} -eq 1 ]; then
	colecho WARN "Removed $customer from customer list"
	sed -i "/$customer/d" new_customers.txt
 elif [ ${check_name} -eq 0 ]; then
	colecho INFO "Environment with $customer name was not present in Sleeper"
 else
	equal_name=$(cat new_customers.txt | grep $customer)
	echo $equal_name
	colecho WARN "Please choose environment name that need remove"
	read choice_name
	sed -i "/$choice_name/d" new_customers.txt
 fi;
done

colecho INFO "Removing worker name from worker list"
for worker in $(cat list_format);
do check_worker=$(cat tomcat.workers | grep $worker | wc -l);
 if [ "$check_worker" -eq 1 ]; then
	colecho WARN "Removed worker $worker from customer list"
        sed -i "/$worker/d" tomcat.workers
 elif [ "$check_worker" -eq 0 ]; then
	colecho WARN "Worker with $customer name was not present in Sleeper"
 else
        equal_worker=$(cat tomcat.workers | grep $worker | awk -F "." '{print $2}')
	echo $equal_worker
        colecho WARN "Please choose worker that need remove"
        read choice_worker
        sed -i "/$choice_worker/d" tomcat.workers
 fi;
done






