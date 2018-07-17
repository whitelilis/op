#!/usr/bin/env python
# coding=utf-8

import sys
import glob
import os
import inspect
#################################################################################################

pwd = os.path.abspath(os.path.dirname(inspect.stack()[0][1]))
import socket
hostname = socket.gethostname()
################################################################################################

#2015-10-29 08:38:16,019 INFO org.apache.hadoop.yarn.server.nodemanager.containermanager.monitor.ContainersMonitorImpl: Memory usage of ProcessTree 37166 for container-id container_1446071590784_2772_01_000035: 604.3 MB of 2.5 GB physical memory used; 2.7 GB of 5.3 GB virtual memory used
#2015-10-29 08:38:16,076 INFO org.apache.hadoop.yarn.server.nodemanager.containermanager.monitor.ContainersMonitorImpl: Memory usage of ProcessTree 36821 for container-id container_1446071590784_2756_01_000538: 635.2 MB of 1.5 GB physical memory used; 2.7 GB of 3.1 GB virtual memory used
#2015-10-29 08:38:16,128 INFO org.apache.hadoop.yarn.server.nodemanager.containermanager.monitor.ContainersMonitorImpl: Memory usage of ProcessTree 30576 for container-id container_1446071590784_2816_01_000001: 404.3 MB of 1.5 GB physical memory used; 1.8 GB of 3.1 GB virtual memory used
#2015-10-29 08:38:16,179 INFO org.apache.hadoop.yarn.server.nodemanager.containermanager.monitor.ContainersMonitorImpl: Memory usage of ProcessTree 23033 for container-id container_1446071590784_2697_01_000407: 432.5 MB of 2.5 GB physical memory used; 2.7 GB of 5.3 GB virtual memory used
#2015-10-29 08:38:16,506 INFO SecurityLogger.org.apache.hadoop.ipc.Server: Auth successful for appattempt_1446071590784_2697_000001 (auth:SIMPLE)
#2015-10-29 08:38:16,510 INFO org.apache.hadoop.yarn.server.nodemanager.containermanager.ContainerManagerImpl: Stopping container with container Id: container_1446071590784_2697_01_000407
#2015-10-29 08:38:16,510 INFO org.apache.hadoop.yarn.server.nodemanager.NMAuditLogger: USER=track_report IP=10.10.1.20   OPERATION=Stop Container Request        TARGET=ContainerManageImpl   RESULT=SUCCESS  APPID=application_1446071590784_2697    CONTAINERID=container_1446071590784_2697_01_000407
#2015-10-29 08:38:16,510 INFO org.apache.hadoop.yarn.server.nodemanager.containermanager.container.Container: Container container_1446071590784_2697_01_000407 transitioned from RUNNING to KILLING
#2015-10-29 08:38:16,511 INFO org.apache.hadoop.yarn.server.nodemanager.containermanager.launcher.ContainerLaunch: Cleaning up container container_1446071590784_2697_01_000407
#2015-10-29 08:38:16,526 WARN org.apache.hadoop.yarn.server.nodemanager.DefaultContainerExecutor: Exit code from container container_1446071590784_2697_01_000407 is : 143
#

log_pattern = '/data/hadooplogs/yarn-*.log'

check_result = {}

count_dict = {}
sum_dict = {}


for f in glob.glob(log_pattern):
    with open(f) as fd:
        for line in fd:
            if 'org.apache.hadoop.yarn.server.nodemanager.containermanager.monitor.ContainersMonitorImpl: Memory usage' in line:
                parts = line.strip().split()
                limit = parts[15]
                if limit == '1.5':
                    limit = 'map'
                elif limit == '2.5':
                    limit = 'reduce'
                else:
                    limit = 'other'
                used_unit = parts[13]
                try:
                    used  = float(parts[12])
                    if used_unit == 'GB':
                        used = used * 1024
                    if not check_result.has_key(limit):
                        check_result[limit] = used
                        count_dict[limit] = 1
                        sum_dict[limit] = used
                    else:
                        count_dict[limit] = count_dict[limit] + 1
                        sum_dict[limit] = sum_dict[limit] + used
                        if used > check_result[limit]:
                            check_result[limit] = used
                except:
                            pass

import time
ts = int(time.time())
def report_one(catalog, name, value, tags = ''):
    print 'hadoop.%s.%s %d %f host=%s %s' % (catalog, name, ts, value, hostname, tags)

for k in check_result.keys():
    report_one('memcheck_MB', k, check_result[k])
    report_one('memcheck_MB_avg', k, sum_dict[k] / count_dict[k])
