#!/bin/sh
machine=$1
flag_file_name=SCP_FLAG


touch $flag_file_name 
scp $flag_file_name $1:/tmp/ 2>/dev/null >/dev/null
if [ $? -eq 0 ]
then
	echo Y
	exit 0
else
	echo N
	exit 1
fi 

