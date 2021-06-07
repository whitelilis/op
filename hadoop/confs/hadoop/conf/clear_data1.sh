#!/bin/bash
/etc/init.d/hadoop-hdfs-datanode stop
umount -l /data1
chown root:root /data1
chmod 755 /data1

sleep 14100
/etc/init.d/hadoop-hdfs-datanode start
/etc/init.d/hadoop-hdfs-datanode start

