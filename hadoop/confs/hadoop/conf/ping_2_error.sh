#!/bin/bash
cwd=$(cd $(dirname $0); pwd)
cd  $cwd
source /etc/profile

count=0

for f in $(shuf /etc/hadoop/conf/v_dns | head -20)
do
    ping -c 1 -W 3 $f > /dev/null 2>&1
    first=$?
    ping -c 1 -W 3 $f > /dev/null 2>&1
    second=$?
    if [ $first -ne 0 ] && [ $second -ne 0 ]
    then
        echo $(date +%F_%T) $(hostname) '--' $f >> /tmp/ping_error_log_2
        count=$[ $count + 1 ]
    fi
done

echo hadoop.net.ping_error_2 $(date +%s) $count.0 host=$(hostname)

