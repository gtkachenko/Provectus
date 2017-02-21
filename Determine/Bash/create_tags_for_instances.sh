#!/bin/bash
cd /opt/auto

for i in $(cat new_customers.txt); do cat tomcat.workers | grep worker.$i.host | awk -F "=" '{print $2}' | sort -u >> /tmp/actual_customer_list; done
for i in $(cat /tmp/actual_customer_list ); do aws ec2 describe-instances --filter "Name=private-ip-address ,Values=$i" | jq  '.Reservations[].Instances[] | .InstanceId' | cut -f 2 -d \"; done >> /tmp/all_instance_id.txt
cd /tmp
for i in $(cat all_instance_id.txt); do aws ec2 create-tags --resources $i --tags Key=Sleeper,Value=yes; done
rm -f actual_customer_list
rm -f all_instance_id.txt
