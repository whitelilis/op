#!/bin/sh


kk(){
	web_dir=$(date +%F)
	mkdir -p $web_dir
	file="$web_dir/$(date +%T)"
	links -dump 'http://10.100.20.1:50070/dfshealth.jsp' > $file 2> /dev/null
	./ana_nn_web.pl $file
	sleep 60
	kk
}

kk &
