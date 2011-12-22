#!/bin/sh
ps ux | grep -v grep | grep job_main.pl >/dev/null 2>&1
if [ $? -ne 0 ] # not running
then
	cd /home/$(whoami)/job_statistic && perl ./job_main.pl /opt/hadoop/logs/hadoop-hadoop-jobtracker-GS-DPO-SEV0002.log &
else
	echo "job_statistic is running"
fi

