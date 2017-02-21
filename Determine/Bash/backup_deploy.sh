#!/bin/bash
customer=$1
ticket=$2
user=$(ps aux | grep -v grep | grep -v root | grep "/$customer/"|  awk '{print $1}')
clm_path=inf/releases/$customer
clm_conf=clients/$customer/conf
clm_base=clients/$customer
clm_supp=clients/$customer/appSupport	

function colecho {

    case "$1" in
      INFO ) echo -en "\e[96m" ;;
      WARN ) echo -en "\e[33m" ;;
      FAIL ) echo -en "\e[31m" ;;
    esac
    echo $2
    echo -en "\e[0m"
}

function usage() {
	colecho INFO "Usage: backup_deploy.sh please specify customer and  ticket number"
}
	if [[ -z $customer ]] || [[ -z $ticket ]]
	then
		usage	
		exit 1
	fi
	case $user in
                stdstg)
                        mkdir -p /CLM_STD_STAGE/$clm_base/preWOS-$ticket
                        cp -r /CLM_STD_STAGE/$clm_conf /CLM_STD_STAGE/$clm_base/preWOS-$ticket
                        rsync --copy-unsafe-links -avz /CLM_STD_STAGE/$clm_supp --exclude=temp --exclude=attachment* --exclude=docusign* --exclude=contractindexes /CLM_STD_STAGE/$clm_base/preWOS-$ticket
                        cp -a /CLM_STD_STAGE/$clm_path /CLM_STD_STAGE/$clm_path-preWOS-$ticket
                        chown -R stdstg.stdstg /CLM_STD_STAGE/$clm_path-preWOS-$ticket && chown -R stdstg.stdstg /CLM_STD_STAGE/$clm_base/preWOS-$ticket
                    	ls -l /CLM_STD_STAGE/inf/releases | grep $customer-preWOS-$ticket && ls -l /CLM_STD_STAGE/$clm_base/ | grep preWOS-$ticket && ls -l /CLM_STD_STAGE/$clm_base/preWOS-$ticket/appSupport
			su - stdstg
        ;;
                stdsvc)
                        mkdir -p /CLM_STD/$clm_base/preWOS-$ticket
                        cp -r /CLM_STD/$clm_conf /CLM_STD/$clm_base/preWOS-$ticket
                        rsync --copy-unsafe-links -avz /CLM_STD/$clm_supp --exclude=temp --exclude=attachment* --exclude=docusign* --exclude=contractindexes /CLM_STD/$clm_base/preWOS-$ticket
                        cp -a /CLM_STD/$clm_path /CLM_STD/$clm_path-preWOS-$ticket
                        chown -R stdsvc.stdsvc /CLM_STD/$clm_path-preWOS-$ticket && chown -R stdsvc.stdsvc /CLM_STD/$clm_base/preWOS-$ticket
			ls -l /CLM_STD/inf/releases | grep $customer-preWOS-$ticket && ls -l /CLM_STD/$clm_base/ | grep preWOS-$ticket && ls -l /CLM_STD/$clm_base/preWOS-$ticket/appSupport                        
			su - stdsvc
        ;;
                perfsvc)
                        mkdir -p /CLM_PERF/$clm_base/preWOS-$ticket
                        cp -r /CLM_PERF/$clm_conf /CLM_PERF/$clm_base/preWOS-$ticket
                        rsync --copy-unsafe-links -avz /CLM_PERF/$clm_supp --exclude=temp --exclude=attachment* --exclude=docusign* --exclude=contractindexes /CLM_PERF/$clm_base/preWOS-$ticket
                        cp -a /CLM_PERF/$clm_path /CLM_PERF/$clm_path-preWOS-$ticket
                        chown -R perfsvc.perfsvc /CLM_PERF/$clm_path-preWOS-$ticket && chown -R perfsvc.perfsvc /CLM_PERF/$clm_base/preWOS-$ticket
                        ls -l /CLM_PERF/inf/releases | grep $customer-preWOS-$ticket && ls -l /CLM_PERF/$clm_base/ | grep preWOS-$ticket && ls -l /CLM_PERF/$clm_base/preWOS-$ticket/appSupport        
			su - perfsvc
        ;;
                perfstg)
                        mkdir -p /CLM_PERF_STAGE/$clm_base/preWOS-$ticket
                        cp -r /CLM_PERF_STAGE/$clm_conf /CLM_PERF_STAGE/$clm_base/preWOS-$ticket
                        rsync --copy-unsafe-links -avz /CLM_PERF_STAGE/$clm_supp --exclude=temp --exclude=attachment* --exclude=docusign* --exclude=contractindexes /CLM_PERF_STAGE/$clm_base/preWOS-$ticket
                        cp -a /CLM_PERF_STAGE/$clm_path /CLM_PERF_STAGE/$clm_path-preWOS-$ticket
                        chown -R perfstg.perfstg /CLM_PERF_STAGE/$clm_path-preWOS-$ticket && chown -R perfstg.perfstg /CLM_PERF_STAGE/$clm_base/preWOS-$ticket
                        ls -l /CLM_PERF_STAGE/inf/releases | grep $customer-preWOS-$ticket && ls -l /CLM_PERF_STAGE/$clm_base/ | grep preWOS-$ticket && ls -l /CLM_PERF_STAGE/$clm_base/preWOS-$ticket/appSupport
			su - perfstg
        ;;
                esssvc)
                        mkdir -p /CLM_ESS/$clm_base/preWOS-$ticket
                        cp -r /CLM_ESS/$clm_conf /CLM_ESS/$clm_base/preWOS-$ticket
                        rsync --copy-unsafe-links -avz /CLM_ESS/$clm_supp --exclude=temp --exclude=attachment* --exclude=docusign* --exclude=contractindexes /CLM_ESS/$clm_base/preWOS-$ticket
                        cp -a /CLM_ESS/$clm_path /CLM_ESS/$clm_path-preWOS-$ticket
                        chown -R esssvc.esssvc /CLM_ESS/$clm_path-preWOS-$ticket && chown -R esssvc.esssvc /CLM_ESS/$clm_base/preWOS-$ticket
                        ls -l /CLM_ESS/inf/releases | grep $customer-preWOS-$ticket && ls -l /CLM_ESS/$clm_base/ | grep preWOS-$ticket && ls -l /CLM_ESS/$clm_base/preWOS-$ticket/appSupport
			su - esssvc
        ;;
        esac


