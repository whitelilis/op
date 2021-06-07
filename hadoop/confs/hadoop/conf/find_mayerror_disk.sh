#!/bin/bash
for m in $(cat little_disk_slave)
do
	used=$(ssh $m "df -h /data1" 2>&1 | tail -1 | awk '{print $5}' | sed -e 's/%//')
	if [ $used -lt 40 ] # little dist machine
	then
		echo $m >> cleared_data1_machines
	fi
done
