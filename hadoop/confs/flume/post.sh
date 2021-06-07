#!/bin/bash
cwd=$(cd $(dirname $0); pwd)
cd  $cwd
source /etc/profile

export JAVA_HOME=$cwd/jdk1.7.0_79
export PATH=$JAVA_HOME/bin:$PATH

flume_home=$cwd/flume

sed -e "s@JH_HOLDER@$JAVA_HOME@" $flume_home/conf/flume-env.tpl >  $flume_home/conf/flume-env.sh
chmod +x $flume_home/conf/flume-env.sh

cd $flume_home && ./start.sh
