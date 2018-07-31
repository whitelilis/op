#!/bin/sh
#set -x

################ varibales #########################
cwd=$(dirname $0)
rdir="$cwd/../results"
ldir="$cwd/../logs"
hadoop_bin='/opt/hadoop/program/bin/hadoop'
ft_time=120
ft="$cwd/ft 240 "
put_file="$cwd/../data/put_file"
put_location="/tmp/monitor/put_file"

############### argumes  ############################
hdfs_ok_sec=300
jobtracker_ok_sec=300
more_dead_sec=300
dead_max_limit=42
read_write_sec=600

################# functions #####################
msg(){
	message="OK"
	check_no=$1
	if [ $check_no -eq 137 ]
	then
		message="TIMEOUT"
	else
	 	if [ $check_no -gt 0 ]
		then
			message="ERROR"
		fi
	fi
	echo "$check_no  $message:$(basename $0)"
}

rfile(){
	echo $rdir"/"$(basename $0)".r"
}

lfile(){
	echo $ldir"/"$(basename $0)".log"
}


