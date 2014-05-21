#!/usr/bin/env python
# coding=utf-8

import sys
import os
import re

result = {}
count = {}
keys = ('cpu', 'mem', 'fio')

for key_str in keys:
    result[key_str] = 0
    count[key_str]  = 0


re.compile(r'^\s*\d+.\d+\s*$')
pattern_line = re.compile('.*==+\s*(\w+)\s*==+.*')
cpu_line = re.compile('.*execution time \(avg/stddev\):\s+([0-9.]+)/.*')
mem_io_line = re.compile('.*\(([0-9.]+)\s*M[Bb]/sec.*')

current_key = ''

for f in sys.argv:
    with open(f) as fd:
        for line in fd:
            key_match = pattern_line.match(line)
            if key_match:
                current_key = key_match.groups()[0]
            if current_key == 'cpu':
                result_line = cpu_line
            else:
                result_line = mem_io_line
            result_match = result_line.match(line)
            if result_match:
                result[current_key] += float(result_match.groups()[0])
                count[current_key]  += 1


for k in keys:
    print '%s : %s' % (k, result[k]/count[k])
