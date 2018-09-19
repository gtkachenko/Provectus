#!/bin/bash
os_user='user'
host='*'
key='*'

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

colecho INFO "Checking that $customer is not present in sleeper"
result=$(ssh -t -t ${os_user}@${host} -i ${key} " cat /opt/auto/new_customers.txt | grep $customer")
if [ -z ${result} ]; then
	colecho INFO "$customer is not present in sleeper and it will be add"
else
	colecho FAIL "$customer is already present in sleeper "
        exit 1
fi

colecho INFO "Checking that $customer was in Sleeper before"
check=$(ssh -t -t ${os_user}@${host} -i ${key} " cat /opt/auto/tomcat.workers | grep $customer")
if [ -z ${check} ]; then
        colecho FAIL "$customer has never been in Sleeper before or you specified incorrect environment name. So you should check name or run another action"
	exit 1
else
        colecho INFO "$customer was in Sleeper before and it will be added again"
fi


colecho WARN "Adding $customer in Sleeper"
ssh -t -t ${os_user}@${host} -i ${key} "
echo $customer >> /opt/auto/new_customers.txt
"

colecho INFO "Checking that $customer was  added in Sleeper"
check_adding=$(ssh -t -t ${os_user}@${host} -i ${key} " cat /opt/auto/new_customers.txt | grep $customer")
if [ -z ${check} ]; then
	colecho FAIL "Something went wrong $customer  was not added in sleeper"
	exit 1
else 
	colecho INFO "$customer was successfully added in Sleeper"
fi

colecho WARN "Restartind sleeper for applying changes"
#ssh -t -t ${os_user}@${host} -i ${key} "
#sudo /opt/auto/switcher_daemon_down.pl -a restart
#"

colecho INFO "Getting ip addres EC2-instance"
worker_propertie=$(ssh -t -t ${os_user}@${host} -i ${key} " cat /opt/auto/tomcat.workers  | grep $customer ")
instance_ip=$(echo $worker_propertie | awk -F "=" '{print $2}')

colecho INFO "Getting instance id"
instance_id=$(aws ec2 describe-instances --filter "Name=private-ip-address ,Values=${instance_ip}" | jq  '.Reservations[].Instances[] | .InstanceId' | cut -f 2 -d \")

colecho WARN "Creating tag Sleeper for $customer from AWS"
aws ec2 create-tags --resources ${instance_id} --tags Key=Sleeper,Value=''
