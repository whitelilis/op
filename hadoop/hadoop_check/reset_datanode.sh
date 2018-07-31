#!/bin/sh
./ft "ssh -o StrictHostKeyChecking=no -o ConnectTimeout=30 hadoop@$1 /opt/hadoop/program/bin/hadoop-daemon.sh stop datanode" &
./ft "ssh -o StrictHostKeyChecking=no -o ConnectTimeout=30 hadoop@$1 /opt/hadoop/program/bin/hadoop-daemon.sh stop datanode" &
sleep 5
./ft "ssh -o StrictHostKeyChecking=no -o ConnectTimeout=30 hadoop@$1 /opt/hadoop/program/bin/hadoop-daemon.sh start datanode" &
sleep 2
./ft "ssh -o StrictHostKeyChecking=no -o ConnectTimeout=30 hadoop@$1 /opt/hadoop/program/bin/hadoop-daemon.sh start datanode" 
