#!/bin/sh
aa=$(./ft 3 'sleep 10 ')
if [ $? -gt 0 ]
then
	echo just i want
else
	echo bad
fi
 
