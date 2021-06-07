#!/bin/bash
cwd=$(dirname $0)
cd  $cwd
source /etc/profile

today=$(date +%y%m%d)
conf_dir=/etc/hadoop/conf
bak_dir=~/conf_bak/$today

mkdir -p $bak_dir
pushd $conf_dir

for file in dns exclude-dns core-site.xml hdfs-site.xml yarn-site.xml fair-scheduler.xml hadoop-policy.xml mapred-site.xml schedulers log4j.properties rackware
do
    cp -a $file $bak_dir
done

popd
