#!/bin/bash
#cleanup, version 2
#Для работы сценария требуются права root

LOG_DIR=/var/log
ROOT_UID=0	#Only user with $UID0 has privileges as root
LINES=200	#Number of save lines
E_XCD=66	#Can not change directory
E_NOTROOT=67	#Sign isn't root


if [ "$UID" -ne "$ROOT_UID" ]
then
    echo "You need to be root"
    exit $E_NOTROOT
fi

if [ -n "$1" ]
#Check arguments in command line
then
    lines=$1
else
    lines=$LINES # Defaut value if value is not not set in command line
fi

cd $LOG_DIR

if [ `pwd` != "$LOG_DIR" ]

then
    echo "Can not go in $LOG_DIR"
    exit $E_XCD
fi	#Check folder before clear log files

tail -$lines messages > mesg.tmp # Save last lines in log files
mv mesg.tmp messages

cat /dev/null > wtmp 
echo "Log files cleared"

exit 0
