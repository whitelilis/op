#!/usr/bin/python

hadoop_conf = {
    'confs': 'hdfs-site.xml,core-site.xml,yarn-site.xml,mapred-site.xml',
    'conf_property': 'name,value,final',
}

apollo_conf = {
    'url': 'http://58.215.174.180:8080/configfiles/json/hadoop-conf/default/application?',        
}
