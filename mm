#!/usr/bin/env python
#-*- coding:UTF-8 -*-
# a script generate graph from opentsdb for host cpu/mem/network/disk
import sys
import webbrowser
sys.path.append("libs")

import datetime

now = datetime.datetime.now()
start = now - datetime.timedelta(hours=1)

start_str = start.strftime("%Y/%m/%d-%H:%M:%S")

tsdb_uri = 'http://10.10.2.61:8484'

host_str = sys.argv[1]


cpu_disk_url = tsdb_uri + '/#start=' + start_str + '&m=p90:cpu.usr%7Bhost=' + host_str + '%7D&o=axis%20x1y2&m=p90:cpu.sys%7Bhost=' + host_str + '%7D&o=axis%20x1y2&m=p90:iostat.disk.util%7Bhost=' + host_str + '%7D&o=&yrange=%5B0:%5D&y2range=%5B0:%5D&key=out%20center%20top%20box&wxh=1260x580&style=linespoint&autoreload=15'



mem_net_url = tsdb_uri + '/#start=' + start_str + '&m=sum:proc.meminfo.anonpages%7Bhost=' + host_str + '%7D&o=axis%20x1y2&m=sum:proc.meminfo.memtotal%7Bhost=' + host_str + '%7D&o=axis%20x1y2&m=sum:rate:proc.net.bytes%7Bdirection=*,host=' + host_str + ',iface=em1%7D&o=&yrange=%5B0:%5D&y2range=%5B0:%5D&key=out%20center%20top%20box&wxh=1260x580&style=linespoint&autoreload=15'



#print mem_net_url
#print cpu_disk_url

webbrowser.open(cpu_disk_url, new=2)
webbrowser.open(mem_net_url, new=2)
#print webbrowser.get()

