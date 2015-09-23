#!/usr/bin/env python
# coding=utf-8

import urllib2
import json
import time

import socket
hostname = socket.gethostname()

jmx_port = 50070

def report_jmx():
    uri = 'http://%s:%s/jmx' % (hostname, jmx_port)
    time_limit = 2

    try:
        json_str = urllib2.urlopen(uri, timeout = time_limit).read()
        json_obj = json.loads(json_str)
        ts = int(time.time())
        def report_one(index, name_and_key, new_tag = ''):
            print 'hadoop.namenode.%s %d %f cluster=%s %s' % (name_and_key, ts, json_obj['beans'][index][name_and_key], hostname, new_tag)

        for i in range(len(json_obj['beans'])):
            metric_dict = json_obj['beans'][i]
            if 'name=RpcActivityForPort' in metric_dict['name']: # rpc metrics
                report_one(i, 'CallQueueLength')
            elif 'name=RpcDetailedActivityForPort' in metric_dict['name']:
                report_one(i, 'GetFileInfoAvgTime')
                report_one(i, 'CreateAvgTime')
                report_one(i, 'MkdirsAvgTime')
                report_one(i, 'DeleteAvgTime')
                report_one(i, 'RenameAvgTime')
                report_one(i, 'FsyncAvgTime')
                report_one(i, 'AppendAvgTime')
            elif 'name=JvmMetrics' in metric_dict['name']:
                report_one(i, 'MemHeapUsedM')
                report_one(i, 'MemHeapMaxM')
                report_one(i, 'ThreadsRunnable')
                report_one(i, 'ThreadsBlocked')
                report_one(i, 'ThreadsWaiting')
            elif 'name=FSNamesystemState' in metric_dict['name']:
                report_one(i, 'CapacityTotal')
                report_one(i, 'CapacityUsed')
                report_one(i, 'BlocksTotal')
                report_one(i, 'FilesTotal')
                report_one(i, 'UnderReplicatedBlocks')
                report_one(i, 'ScheduledReplicationBlocks')
                report_one(i, 'NumLiveDataNodes')
                report_one(i, 'NumDeadDataNodes')

    except:
        pass

if __name__ == '__main__':
    report_jmx()
