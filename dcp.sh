#!/bin/bash
#set -x

bin_name=$(basename $0)

d (){
        pdsh -R exec -u 27 -f 50 -w ^$@
}

help () {
        echo "useage : $bin_name machine_list src(single_file) dst"
}


if [ $# -ne 3 ]
then
        help
        exit 1
fi


machine_list=$1
raw_machine_list=$1
src=$2
dst=$3
md5=$(md5sum $src | awk '{print $1}')

echo $md5

time=$(date +%F_%T)
ok_list="/tmp/ok_$time"
bad_list="/tmp/bad_$time"

>$ok_list
>$bad_list

all_count=$(wc -l $machine_list | awk '{print $1}')
ok_count=$(wc -l $ok_list | awk '{print $1}')


max_loop_count=10

while [ $ok_count -lt $all_count ] && [ $max_loop_count -gt 0 ]
do
        ((max_loop_count =  $max_loop_count - 1))
        
        d $machine_list scp $src %h:$dst
        d $machine_list ssh %h "md5sum $dst" 2>&1 | grep $md5 | awk -F: '{print $1}' >> $ok_list
        sort $raw_machine_list $ok_list $ok_list | uniq -u > $bad_list
        still_bad_count=$(wc -l $bad_list)
        echo "************** still bad : $still_bad_count *******************"
        machine_list=$bad_list
        ok_count=$(sort $ok_list | uniq | wc -l | awk '{print $1}')
done

if [ $ok_count -eq $all_count ]
then
        echo "************** ALL OK ***************"
fi
