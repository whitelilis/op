#!/bin/bash
cwd=$(cd $(dirname $0); pwd)
cd  $cwd
source /etc/profile

count=0

for f in $(shuf /etc/hadoop/conf/v_dns | head -20)
do
    ping -c 1 -W 3 $f > /dev/null 2>&1
    if [ $? -ne 0 ]
    then
        echo $(date +%T) $(hostname) '--' $f >> /tmp/ping_error_log
        count=$[ $count + 1 ]
    fi
done

echo hadoop.net.ping_error $(date +%s) $count.0 host=$(hostname)

