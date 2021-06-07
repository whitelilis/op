#!/bin/bash
echo never > /sys/kernel/mm/redhat_transparent_hugepage/defrag
echo 1 > /proc/sys/vm/overcommit_memory
echo never > /sys/kernel/mm/redhat_transparent_hugepage/enabled
