#!/bin/bash
sed -i.bak -e "/yarn.log-aggregation-enable/{n; s@>.*<@>false<@}" /etc/hadoop/conf/yarn-site.xml
