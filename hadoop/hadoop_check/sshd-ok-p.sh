#!/bin/sh
machine=$1
echo -e '\n' | telnet $machine 22 2>&1 | grep Escape 2>/dev/null >/dev/null
if [ $? -eq 0 ]
then
	echo Y
	exit 0
else
	echo N
	exit 1
fi 

