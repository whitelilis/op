#!/bin/bash
if [ -e /dev/sdk ]
then
	echo $(hostname) 12
else
	echo $(hostname) 8
fi
