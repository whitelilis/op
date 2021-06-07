#!/bin/bash
mem_g=$(free -g | sed -n '2p' | awk '{print $2}')
reserved_g=10

can_use_mem=$[mem_g - $reserved_g ]

if [ $can_use_mem -gt 0 ]
then
	sed -i.bak -e "/cpu-vcores/{n; s@>.*<@>100<@}"   -e  "/yarn.nodemanager.resource.memory-mb/{n; s@>.*<@>${can_use_mem}000<@}"  /etc/hadoop/conf/yarn-site.xml
fi
