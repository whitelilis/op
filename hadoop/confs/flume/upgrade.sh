#!/bin/bash
cwd=$(cd $(dirname $0); pwd)
cd  $cwd
source /etc/profile

export JAVA_HOME=$cwd/../jdk1.7.0_79
export PATH=$JAVA_HOME/bin:$PATH

flume_home=$cwd/../flume

sed -e "s@JH_HOLDER@$JAVA_HOME@" $flume_home/conf/flume-env.tpl >  $flume_home/conf/flume-env.sh
chmod +x $flume_home/conf/flume-env.sh

for pid in $(ps aux | grep -v grep | grep -v upgrade.sh | grep flume | awk '{print $2}')
do
    kill $pid
    kill $pid
    kill -9 $pid
done
killall perl
killall tail

cd $flume_home && ./start.sh
sleep 3
