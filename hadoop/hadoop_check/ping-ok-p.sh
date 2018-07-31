#!/bin/sh
machine=$1
ping -c 1 -w 5 $1 2>/dev/null >/dev/null
if [ $? -eq 0 ]
then
	echo Y
	exit 0
else
	echo N
	exit 1
fi 

