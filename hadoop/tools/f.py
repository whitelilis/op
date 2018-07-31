#!/usr/bin/env python
import os, fnmatch, sys
from subprocess import Popen, PIPE

def break_find(patterns, path):
    result = []
    for root, dirs, files in os.walk(path):
        for name in files:
            for p in patterns:
                if fnmatch.fnmatch(name, p):
                    return os.path.join(root, name)
    return None



def blks_find(blk_file):
    blks = []
    with open(blk_file) as fd:
        for line in fd:
            (blk, other) = line.split('\t')
            blks.append(blk)
    for k in range(1,13):
        print 'will find %d' % k
        xx =  break_find(blks, '/data%d/data' % k)
        if xx:
            print 'find block %s' % xx
            reset_dn()
            break
    # not found
    else:
        print '%s not found' % blks


def reset_dn():
    p = Popen("/etc/init.d/hadoop-hdfs-datanode restart", shell=True, stdout=PIPE, stderr=PIPE)
    p.wait()



if __name__ == '__main__':
     blks_find(sys.argv[1])
