#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os,sys,yaml

head = """<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<!--
/**
 * Copyright 2010 The Apache Software Foundation
 *
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
-->
<configuration>

"""
tail = """
</configuration>
"""
if __name__ == '__main__':
    conf = yaml.load(open(os.path.join(sys.path[0], "config.yaml")))
    for key1 in conf.keys():
        #生成文件放在/tmp目录
        with open('./tmp/' + key1 ,'w') as f:
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
