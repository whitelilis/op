#!/bin/sh
machine=$1
ssh $1 '/opt/hadoop/program/bin/hadoop version' 2>/dev/null >/dev/null
#ssh $1 '/opt/hadoop/program/bin/hadoopk version' 2>/dev/null >/dev/null
if [ $? -eq 0 ]
then
	echo Y
	exit 0
else
	echo N
	exit 1
fi 

