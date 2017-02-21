#!/bin/bash
user=$(whoami)
path=/home/$user/Downloads/
path_put=/home/$user/OutagesLog
file_name=$1
full_path=${path}${file_name};
function usage() {
	echo INFO "Usage: parse_log.sh please specify name of files with logs"
}
	if [[ -z $file_name ]]
	then
		usage
		exit 1
	fi
if [ $file_name == "catalina.out" ]; then
	cat $full_path | grep -A 15  error > $path_put/catalina/error
	cat $full_path | grep -A 15 OutOfMemoryError > $path_put/catalina/outofmemory
	cat $full_path | grep -A 15 Full\ GC > $path_put/catalina/fullGC
	cat $full_path | grep -A 15 EXCEPTION > $path_put/catalina/exception
	cat $full_path | grep -A 15 BLOCKED > $path_put/catalina/block_threads
	cat $full_path | grep -A 15 StackOverflowError > $path_put/catalina/stackOverflowError
	cat $full_path | grep -A 15 java.lang.IllegalStateException  > $path_put/catalina/IllegalStateException
	cat $full_path | grep -A 15 java.lang.NullPointerException > $path_put/catalina/NullPointerException
    cat $full_path | grep -A 15 Import > $path_put/catalina/Improt
    cat $full_path | grep -A 15 import > $path_put/catalina/improt
rm -f /home/$user/Downloads/$file_name
fi

if [ $file_name == "SCM.log" ];then
    cat $full_path | grep -A 15 error > $path_put/SCM/error
	cat $full_path | grep -A 15 ERROR > $path_put/SCM/Error
	cat $full_path | grep -A 15 WARN > $path_put/SCM/warning
    cat $full_path | grep -A 15 Improt > $path_put/SCM/Import
    cat $full_path | grep -A 15 import > $path_put/SCM/import
rm -f /home/$user/Downloads/$file_name
fi

if [ $file_name == "messages" ]; then
	cat $full_path | grep  -A 15 killed > $path_pit/SCM/killed_process
fi
<<<<<<< HEAD

=======
rm -f /home/$user/Downloads/$file_name
>>>>>>> e0c642ef0aecb5edcd4f2559f67cc7706a057725
