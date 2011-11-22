#!/bin/sh


kk(){
	web_dir=$(date +%F)
	mkdir -p $web_dir
	file="$web_dir/$(date +%T)"
	links -dump 'http://10.100.20.2:50030/jobtracker.jsp' > $file 2> /dev/null
	./ana_jt_web.pl $file
	sleep 60
	kk
}

kk &
