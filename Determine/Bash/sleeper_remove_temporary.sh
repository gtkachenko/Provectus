#!/bin/bash
os_user='*'
host='*'
key='/home/*/.ssh/*'

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

colecho INFO "Getting ip addres EC2-instance"
worker_propertie=$(ssh -t -t ${os_user}@${host} -i ${key} " cat /opt/auto/tomcat.workers  | grep $customer ")
instance_ip=$(echo $worker_propertie | awk -F "=" '{print $2}')

colecho INFO "Getting instance id"
instance_id=$(aws ec2 describe-instances --filter "Name=private-ip-address ,Values=${instance_ip}" | jq  '.Reservations[].Instances[] | .InstanceId' | cut -f 2 -d \")

colecho WARN "Removing tag Sleeper for $customer from AWS"
aws ec2 delete-tags --resources ${instance_id} --tags Key=Sleeper
