#!/bin/sh
#set -x
machine=$1
ssh $1 "'ps aux | grep -v grep | grep org.apache.hadoop.hdfs.server.datanode.DataNode'" 2>/dev/null >/dev/null
if [ $? -eq 0 ]
then
	echo Y
	exit 0
else
	echo N
	exit 1
fi 

