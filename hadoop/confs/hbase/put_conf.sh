#!/bin/bash

for regionserver in `cat regionservers.txt`
do
	scp hbase-site.xml $regionserver:/etc/hbase/conf
done
