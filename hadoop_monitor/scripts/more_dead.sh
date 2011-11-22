#!/bin/sh

check(){
	WDIR=$(dirname $0)

	. $WDIR/init_and_common.sh


	date +%F_%T >> $(lfile)
##########################################
	dead_num=$($hadoop_bin dfsadmin -report | grep "Datanodes available" | awk '{print $6}')

	check_no=0
	if [ $dead_num -gt $dead_max_limit ]
	then
		check_no=2
	fi

	msg $check_no >$(rfile)

	echo "dead datanode : $dead_num" >> $(lfile)
#########################################
	sleep $more_dead_sec
	check
}

check &

