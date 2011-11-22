#!/bin/sh
log_file='/home/hadoop/system_static.log'
pid_file='/home/hadoop/system_static.pid'

if [ -e $pid_file ]
then
    pid=$(cat $pid_file)
    ps ux | awk '{print $2}' | grep $pid
    if [ $? -eq 0 ]
        then
        exit 1;
    fi
fi



static(){
    echo $$ > $pid_file
    date +%F_%T >> $log_file
    sar -ubr -n DEV,EDEV 2 10 >> $log_file
    sleep 40
    static
}


static
