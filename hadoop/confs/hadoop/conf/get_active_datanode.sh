curl http://backnn.master.adh:50070/jmx\?qry\=Hadoop:service\=NameNode,name\=NameNodeInfo | grep  LiveNodes| sed 's/ //g'|sed 's/{//g'|sed 's/}//g'| sed 's/\"//g' | sed 's/\\//g'| sed 's/:/,/g'|tr ',' '\n' | grep slave.adh | sort | uniq | sort > active_datanode
