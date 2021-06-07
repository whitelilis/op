#!/bin/bash
cwd=$(dirname $0)
cd  $cwd
source /etc/profile


now_hour=$(date +%H)
xml_dir=/etc/hadoop/conf/schedulers

maybe_conf_from_now=$xml_dir/$now_hour

if [ -e $maybe_conf_from_now ]
then
    cp $maybe_conf_from_now /etc/hadoop/conf/fair-scheduler.xml
fi
