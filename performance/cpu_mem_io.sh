#!/bin/bash
cwd=$(dirname $0)
cd  $cwd

core_number=$(grep processor /proc/cpuinfo | wc -l)
core_number=2
sysbench_cmd="sysbench --num-threads=$core_number"
fio_cmd="$sysbench_cmd --test=fileio --file-total-size=3G --file-test-mode=rndrw --file-rw-ratio=4 --file-extra-flags=direct "
log_file=logs_$(date +%F_%T)
yum install -y sysbench

which sysbench
if [ $? -ne 0 ]
then
    echo 'no sysbench found, exit'
    exit 1
fi

(

echo "========== cpu ==============="
$sysbench_cmd --test=cpu run
echo "========== mem ==============="
$sysbench_cmd --test=memory run
echo "========== fio ==============="

$fio_cmd prepare
$fio_cmd run
$fio_cmd cleanup
) > $log_file
