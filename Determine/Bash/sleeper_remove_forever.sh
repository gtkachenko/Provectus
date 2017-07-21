#!/bin/bash
os_user='*'
host='*'
key='/home/*/.ssh/*'
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
rm -f $filename


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

	sed -i "/${customer}/d" new_customers.txt
 elif [ ${check_name} -eq 0 ]; then
	colecho INFO "Environment with $customer name was not present in Sleeper"
 else
	equal_name=$(cat new_customers.txt | grep $customer)
	echo $equal_name
	colecho WARN "Please choose environment name that need remove"
	read choice_name
	sed -i "/${choice_name}$/d" new_customers.txt
	colecho WARN "Removed worker $choice_name from customer list"
 fi;
done

colecho INFO "Removing worker name from worker list"
for worker in $(cat list_format);
do check_worker=$(cat tomcat.workers | grep $worker | wc -l);
 if [ "$check_worker" -eq 1 ]; then
	colecho WARN "Removed worker $worker from customer list"
        sed -i "/${worker}/d" tomcat.workers
 elif [ "$check_worker" -eq 0 ]; then
	colecho WARN "Worker with $customer name was not present in Sleeper"
 else
        equal_worker=$(cat tomcat.workers | grep $worker | awk -F "." '{print $2}')
	echo $equal_worker
        colecho WARN "Please choose worker that need remove"
        read choice_worker
        sed -i "/${choice_worker}\./d" tomcat.workers
        colecho WARN "Removed worker $choice_worker from customer list"
 fi;
done

colecho WARN "Removing file with formatted environments name"
    rm -f list_format

colecho INFO "Formatting file with customer name for removing retarded names"
    mv  new_customers.txt new_customers.txt.unformated
    cat new_customers.txt.unformated | sort -u >> new_customers.txt
    rm -f new_customers.txt.unformated

colecho INFO "Formatting file with worker name for removing retarded workers"
    mv tomcat.workers tomcat.workers.unformated
    cat tomcat.workers.unformated | sort -u >> tomcat.workers
    rm -f tomcat.workers.unformated

colecho INFO "Uploading formatted files with workers and customers names list"
    scp -i ${key} tomcat.workers ${os_user}@${host}:/opt/auto/
    scp -i ${key} new_customers.txt ${os_user}@${host}:/opt/auto/
colecho INFO "Files were successfully updated"

colecho WARN "Restarting sleeper daemon for applying changes"
previous_proc=$(ssh -t -t ${os_user}@${host} -i ${key} "ps aux | grep switcher_daemon | grep -v grep ")
previous_pid=$(echo $previous_proc | awk '{print $2}')
ssh -t -t ${os_user}@${host} -i ${key} "
sudo /opt/auto/switcher_daemon_down.pl -a restart
"

colecho WARN "Checking sleeper daemon restart"
current_proc=$(ssh -t -t ${os_user}@${host} -i ${key} "ps aux | grep switcher_daemon | grep -v grep ")
current_pid=$(echo $current_proc | awk '{print $2}')
if [ ${previous_pid} -eq ${current_pid} ]; then
    colecho FAIL "Sleeper daemon was not restarted "
    exit 1
elif [ -z ${previous_pid}  ]; then
    colecho FAIL "Daemon not running.Please take a look and start daemon if it need"
    exit 1
else
    colecho INFO "Sleeper daemon was restarted successfully"
fi

colecho WARN "Removing configurations files for sleeper that were update"
    rm -f tomcat.workers new_customers.txt
colecho INFO "Environments names were removing from customer list name also deleted workers properties for them"






