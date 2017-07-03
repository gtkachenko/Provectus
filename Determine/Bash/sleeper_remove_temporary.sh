#!/bin/bash -x
os_user='ec2-user'
host='10.100.1.44'
key='/home/gtkachenko/.ssh/Storage.pem'

function colecho {
	case "$1" in
      INFO ) echo -en "\e[96m" ;;
      WARN ) echo -en "\e[33m" ;;
      FAIL ) echo -en "\e[31m" ;;
    esac
    echo $2
    echo -en "\e[0m"
}

colecho INFO "Please specify Environment short name without domain and press Enter:"
read customer

colecho INFO "Checking that $customer is present in sleeper"
result=$(ssh -t -t ${os_user}@${host} -i ${key} " cat /opt/auto/new_customers.txt | grep $customer")
if [ -z ${result} ]; then
	colecho FAIL "You are specified wrong environmet name or this environmet does not exist in sleeper: $customer "
	exit 1
else
	colecho INFO "$customer is present in sleeper and it will be removed"
fi

colecho WARN "Removing from sleeper: $customer"
ssh -t -t ${os_user}@${host} -i ${key} "
sed -i "/$customer/d" /opt/auto/new_customers.txt
"

check=$(ssh -t -t ${os_user}@${host} -i ${key} " cat /opt/auto/new_customers.txt | grep $customer")
if [ -z ${check} ]; then
	colecho INFO "$customer  was temporary removed from sleeper"
else 
	colecho FAIL "Something went wrong and $customer was not removed from sleeper"
	exit 1
fi

colecho WARN "Restartind sleeper for applying changes"
ssh -t -t ${os_user}@${host} -i ${key} "
sudo /opt/auto/switcher_daemon_down.pl -a restart
"

