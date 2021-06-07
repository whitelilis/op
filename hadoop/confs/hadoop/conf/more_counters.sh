#!/bin/bash
sed -i.bak -e "/mapreduce.job.counters.max/{n; s@>.*<@>1000<@}" /etc/hadoop/conf/mapred-site.xml
