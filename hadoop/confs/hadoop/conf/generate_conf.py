#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os,sys,yaml
head = """<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>

"""
tail = """
</configuration>
"""
if __name__ == '__main__':
    conf = yaml.load(open(os.path.join(sys.path[0], "config.yaml")))
    for key1 in conf.keys():
        #生成文件放在/tmp目录
        with open('./' + key1 ,'w') as f:
            f.write(head)
            for key2 in sorted(conf[key1].keys()):
                f.write("    <property>\n")
                f.write("        <name>" + key2 + "</name>\n")
                value = str(conf[key1][key2]).split('#')
                if(value[-1] == 'final'):
                    f.write("        <value>" + '#'.join(value[:-1]) + "</value>\n")
                    f.write("        <final>true</final>\n")
                else:
                    f.write("        <value>" + str(conf[key1][key2]) + "</value>\n")

                f.write("    </property>\n")
            f.write(tail)
