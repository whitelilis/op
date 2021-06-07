#!/bin/bash
source /etc/profile


(while [ 1 ]
do
	date
	jps > /tmp/tmp_jps 2>&1 
	jps_ok=$?
	count_c=$(grep -c YarnChild /tmp/tmp_jps)
	count_a=$(grep -c MRAppMaster /tmp/tmp_jps)
	if [ $jps_ok -eq 0 ] && [ $count_c -eq 0 ] && [ $count_a -eq 0 ]
	then
		/etc/init.d/hadoop-yarn-nodemanager restart
		break
	fi
	sleep 1
done) > /tmp/safe.log 2>&1 &
