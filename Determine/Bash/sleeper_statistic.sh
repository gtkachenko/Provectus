#!/bin/bash
function colecho {
    case "$1" in
	DATE ) echo -en "\e[33m" ;;
	COUN ) echo -en "\e[31" ;;
    esac
    echo $2
    echo -en "\e[0m"
}
today=$(date +"%m-%d-%y")

cd /opt/auto

for i in $(cat new_customers.txt); do cat tomcat.workers | grep worker.$i.host | awk -F "=" '{print $2}' | sort -u >> /tmp/actual_customer_list; done
for i in $(cat /tmp/actual_customer_list ); do aws ec2 describe-instances --filter "Name=private-ip-address ,Values=$i" | jq  '.Reservations[].Instances[] | (.Tags | map(.value=.Value | .key=.Key) | from_entries) as $tags | "\(.State.Name) | \($tags.Name) | \(.InstanceType)"'; done >> /tmp/all_state_tmp.txt

cd /tmp
count_running=$(cat all_state_tmp.txt | grep running >> all_running_hosts)
count_down=$(cat all_state_tmp.txt | grep stopped >> all_down_hosts)
count_up=$(cat all_running_hosts | wc -l)
count_down=$(cat all_down_hosts | wc -l)
echo "Count of up instanses are " $count_up >> all_running_hosts
echo "Count of down instances are "  $count_down >> all_down_hosts


cat all_running_hosts| mail -S smtp=smtp-oregon.selectica.net -r "sleeper@selectica.com" -s "Up hosts from sleeper" gtkachenko@determine.com , webops@determine.com, jpolkowske@determine.com
cat all_down_hosts | mail -S smtp=smtp-oregon.selectica.net -r "sleeper@selectica.com" -s "Down hosts from sleeper" gtkachenko@determine.com , webops@determine.com, jpolkowske@determine.com

rm -f all_running_hosts
rm -f all_down_hosts
rm -f actual_customer_list
rm -f all_state_tmp.txt
