#!/bin/bash
cwd=$(cd $(dirname $0); pwd)
cd  $cwd
source /etc/profile

./bin/flume-ng agent  -c conf -f conf/use.conf -n a1 < /dev/zero  >/dev/null & #-Dflume.root.logger=INFO,console
