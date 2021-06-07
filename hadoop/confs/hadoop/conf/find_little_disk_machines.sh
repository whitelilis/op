#!/bin/bash
for m in $(cat dns)
do
	ssh $m "df -h /data1" 2>&1 | tail -1 | awk '{print $2}' | grep '1.6T'
	if [ $? -eq 0 ] # little dist machine
	then
		echo $m >> little_disk_slave
	fi
done
