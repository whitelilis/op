#!/bin/bash

sed -i.bak -e "/dfs.client.socket-timeout/{n; s@>.*<@>18000<@}" /etc/hadoop/conf/core-site.xml
sed -i.bak -e "/dfs.socket.timeout/{n; s@>.*<@>18000<@}" -e "/dfs.datanode.socket.write.timeout/{n; s@>.*<@>18000<@}" /etc/hadoop/conf/hdfs-site.xml
