#!/usr/bin/env python
# coding=utf-8

import sys
import os
import inspect
#################################################################################################
pwd = os.path.abspath(os.path.dirname(inspect.stack()[0][1]))
import socket
hostname = socket.gethostname()
################################################################################################

import time

ts = int(time.time())

def report_one(catalog, name, value, tags = ''):
    print 'wizard.sys.%s.%s %d %f host=%s %s' % (catalog, name, ts, value, hostname, tags)

def singleFileValue(file):
    with open(file) as fd:
        for line in fd:
            # only the first line
            return line.strip()

def net_values():
    net_file = '/proc/net/dev'
    old_dict = {}
    def net_file2dict(path, d):
        with open(path) as fd:
            for line in fd:
                if ':' in line:
                    (dev, other) = line.split(':')
                    dev = dev.strip()
                    if dev != 'lo':
                        d[dev] = other.strip()
    net_file2dict(net_file, old_dict)

    for d in old_dict.keys():
        try:
            report_one('net', 'speed_MB', int(singleFileValue('/sys/class/net/%s/speed' % d)), 'dev=%s' % d) 
        except:
            pass

def mem_values():
    mem_file = '/proc/meminfo'
    summary = {}
    with open(mem_file) as fd:
        for line in fd:
            if ':' in line:
                (key_, value_k) = line.split()[:2]
                summary[key_] = int(value_k)

    mem_total = summary['MemTotal:']
    mem_used  = summary['MemTotal:'] - summary['Buffers:'] - summary['Cached:'] - summary['MemFree:']
    report_one('mem', 'used_pec', mem_used * 100.0 / mem_total)

def cpu_values():
    cpu_file = '/proc/stat'
    cpu_line1 = ''
    cpu_line2 = ''

    with open(cpu_file) as fd:
        for line in fd:
            cpu_line1 = line
            break
    time.sleep(0.5)
    with open(cpu_file) as fd:
        for line in fd:
            cpu_line2 = line
            break
    s1 = (user1, nice, system1, idle, iowait1, irq, softirq, stealstolen, guest) = cpu_line1.split()[1:]
    sum1 = sum(map(int, s1))
    s2 = (user2, nice, system2, idle, iowait2, irq, softirq, stealstolen, guest) = cpu_line2.split()[1:]
    sum2 = sum(map(int, s2))

    total = sum2 - sum1
    report_one('cpu', 'iowait', (int(iowait2) - int(iowait1)) * 100.0 / total)

if __name__ == '__main__':
    cpu_values()
    mem_values()
    net_values()
