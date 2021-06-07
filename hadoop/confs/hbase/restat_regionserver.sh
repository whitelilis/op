#!/bin/bash

for regionserver in `cat regionservers.txt`
do
	ssh $regionserver /etc/init.d/hbase-regionserver restart
	sleep 30
done
