#!/bin/bash
cwd=$(cd $(dirname $0); pwd)
cd  $cwd
source /etc/profile

aim_dir=$1

bak_dir=bak_for_change_$(hostname)
mkdir -p $bak_dir

for f in passwd shadow group
do
    cp /etc/$f $bak_dir
    cat $aim_dir/$f >> /etc/$f
done
