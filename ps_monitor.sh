#!/bin/sh

cwd="/home/"$(whoami)"/ps_monitor"
log_dir="$cwd/log"
pid_file="$log_dir/ps_monitor.pid"

mkdir -p $log_dir

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
    log_file="$log_dir/"$(date +%d)
    time=$(date +%F_%T)
    echo "---------------------- $time ---------------------  " >> $log_file
    ps -eF | sort -nr -k6>> $log_file
    sleep 60
    static
}


static
