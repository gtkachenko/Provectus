#!/bin/bash -x
cat_base=$(ps aux | grep java | grep -v grep | awk -F "catalina.base=" '{print $2}' | cut -d' ' -f1)
cat_home=$(ps aux | grep java | grep -v grep | awk -F "catalina.home=" '{print $2}' | cut -d' ' -f1)
cat_tmp=$(ps aux | grep java | grep -v grep | awk -F "java.io.tmpdir=" '{print $2}' | cut -d' ' -f1)
java_home=$(ps aux | grep java | grep -v grep | awk '{print $11}' | awk -F "/bin" '{print $1}')
cat_pid=$cat_base/logs/catalina.pid

if [[ -z $cat_base ]]
then
	echo "CLM is not running on this instance"
	exit 1
fi

$cat_base/bin/SLTC.init stop
mv $cat_base/bin $cat_base/bin.old
mkdir -p $cat_base/bin
cd $cat_base/bin/

check_path=$(echo $cat_base | awk -F "/" '{print $2}')
client=$(echo $cat_base | awk -F "/" '{print $4}')

 if [[ "$check_path" == "CLM_STD" ]] || [[ "$check_path" == "CLM_STD_STAGE" ]] || [[ "$check_path" == "CLM_PERF" ]] || [[ "$check_path" == "CLM_PERF_STAGE" ]] || [[ "$check_path" == "CLM_ESS" ]]
 then
    wget http://10.100.1.138/downloads/SLTC.init_like_prod_stage
 else
    wget http://10.100.1.138/downloads/SLTC.init
 fi

in_bin=$(ls -l | grep SLTC.init | awk '{print $9}')
if [ "$in_bin" == "SLTC.init_like_prod_stage" ]
then
mv SLTC.init_like_prod_stage SLTC.init
sed -i "s|/CLM_STD/inf/jdk|$java_home|g" SLTC.init
sed -i "s|/CLM_STD/clients/customer|$cat_base|g" SLTC.init
sed -i "s|/CLM_STD/inf/tomcat|$cat_home|g" SLTC.init
echo JAVA_HOME="$java_home" >> /home/user/.bashrc
echo CATALINA_HOME="$cat_home" >> /home/user/.bashrc
echo CATALINA_BASE="$cat_base" >> /home/user/.bashrc
echo CATALINA_TMPDIR="$cat_tmp" >> /home/user/.bashrc
echo CATALINA_PID="$cat_pid" >> /home/user/.bashrc
chmod +x SLTC.init
./SLTC.init autoln
./SLTC.init add_init
chown -R user.user $cat_base/bin

else
client_dev=$(echo $cat_base | awk -F "/" '{print $5}')
if [[ "$client_dev" == "CLM" ]]
then
	sed -i "s|/Selectica/CUSTOMER|/Selectica|g" SLTC.init
else
	sed -i "s/CUSTOMER/$client_dev/g" SLTC.init
fi
echo JAVA_HOME="$java_home" >> /home/user/.bashrc
echo CATALINA_BASE="$cat_base" >> /home/user/.bashrc
echo CATALINA_PID="$cat_pid" >> /home/user/.bashrc
echo CATALINA_HOME="$cat_home" >> /home/user/.bashrc
echo CATALINA_TMPDIR="$cat_tmp" >> /home/user/.bashrc
chmod +x SLTC.init
./SLTC.init autoln
./SLTC.init add_init
chown -R user.user $cat_base/bin
fi

cp $cat_base/bin.old/catalina.sh $cat_base/bin/
cp $cat_base/bin.old/startup.sh $cat_base/bin/
cp $cat_base/bin.old/shutdown.sh $cat_base/bin/
cp $cat_base/bin.old/setclasspath.sh $cat_base/bin/

/etc/init.d/SLTC.init start
hostname >> /tmp/info_about.txt
ifconfig | grep inet >> /tmp/info_about.txt
