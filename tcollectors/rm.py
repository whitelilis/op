#!/usr/bin/env python
# coding=utf-8

import urllib2
import json
import time

import socket
hostname = socket.gethostname()

jmx_port = 8088

def report_jmx():
    uri = 'http://%s:%s/jmx' % (hostname, jmx_port)
    time_limit = 2

    try:
        json_str = urllib2.urlopen(uri, timeout = time_limit).read()
        json_obj = json.loads(json_str)
        ts = int(time.time())
        def report_one(index, name_and_key, new_tag = ''):
            print 'hadoop.resourcemanager.%s %d %f cluster=%s %s' % (name_and_key, ts, json_obj['beans'][index][name_and_key], hostname, new_tag)

        for i in range(len(json_obj['beans'])):
            metric_dict = json_obj['beans'][i]
            if ',name=QueueMetrics,' in metric_dict['name']: # queue metric
                queue_name = metric_dict['tag.Queue']
                if metric_dict.has_key('tag.User'): # user queue, not group queue
                    queue_name = '%s.%s' % (metric_dict['tag.Queue'], metric_dict['tag.User'])
                report_one(i, 'AppsRunning', 'queue=%s' % queue_name)
                report_one(i, 'AppsPending', 'queue=%s' % queue_name)
                report_one(i, 'AllocatedMB', 'queue=%s' % queue_name)
                report_one(i, 'AllocatedVCores', 'queue=%s' % queue_name)
                report_one(i, 'AllocatedContainers', 'queue=%s' % queue_name)
                report_one(i, 'PendingMB', 'queue=%s' % queue_name)
                report_one(i, 'PendingVCores', 'queue=%s' % queue_name)
                report_one(i, 'PendingContainers', 'queue=%s' % queue_name)
            elif 'name=FSOpDurations' in metric_dict['name']: # fairscheduler info
                report_one(i, 'PreemptCallNumOps')
                report_one(i, 'PreemptCallAvgTime')
            elif 'name=ClusterMetrics' in metric_dict['name']: # cluster info
                report_one(i, 'NumActiveNMs')
                report_one(i, 'NumUnhealthyNMs')
            elif 'name=RpcActivityForPort' in metric_dict['name']: # rpc
                report_one(i, 'CallQueueLength')
                report_one(i, 'NumOpenConnections')
                report_one(i, 'RpcProcessingTimeAvgTime')
    except:
        pass

if __name__ == '__main__':
    report_jmx()
