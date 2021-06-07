#!/bin/bash

sed -i.bak -e "/dfs.datanode.max.transfer.threads/{n; s@>.*<@>4096<@}" -e "/dfs.datanode.max.xcievers/{n; s@>.*<@>4096<@}" /etc/hadoop/conf/hdfs-site.xml
