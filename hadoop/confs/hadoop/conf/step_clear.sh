#!/bin/bash
cwd=$(dirname $0)
cd  $cwd
source /etc/profile

todo_list_file=little_disk_slave

rest_count=$(wc -l $todo_list_file | awk '{print $1}')

if [ $rest_count -gt 0 ]
then
    todo=$(head -1 $todo_list_file)
    echo $(date +%F_%T) "to   clear" $todo >> clear_data1.log
    ssh $todo /etc/hadoop/conf/clear_data1.sh &
    echo $(date +%F_%T) "done command clear" $todo >> clear_data1.log
    sed -i '1d' $todo_list_file
fi
