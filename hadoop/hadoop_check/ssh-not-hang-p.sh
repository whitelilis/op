#!/bin/sh
machine=$1
./ft "ssh $1 'uname -r'" 2>/dev/null >/dev/null
if [ $? -eq 0 ]
then
	echo Y
	exit 0
else
	echo N
	exit 1
fi 

