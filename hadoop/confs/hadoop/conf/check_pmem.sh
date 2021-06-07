#!/bin/bash
sed -i.bak -e "/yarn.nodemanager.pmem-check-enabled/{n; s@>.*<@>true<@}" /etc/hadoop/conf/yarn-site.xml
