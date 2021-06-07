#!/bin/bash
for b in $(awk '{print $1}'  $1)
do
	for f in $(seq 1 12)
	do
		echo "find /data$f/data/current"
		find /data$f/data/current -name "$b*"
	done
done
