#!/bin/bash
#set -x

bin_name=$(basename $0)

same_err_count=0

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

time=$(date +%F_%T)
ok_list="/tmp/ok_$time"
bad_list="/tmp/bad_$time"
no_domain_list="/tmp/no_domian_$time"

maybe_domain_list=$1

perl -lape 's/\..*$//' $maybe_domain_list > $no_domain_list


machine_list=$maybe_domain_list
raw_machine_list=$maybe_domain_list
src=$2
dst=$3
md5=$(md5sum $src | awk '{print $1}')

echo $md5


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
        #sort $raw_machine_list $ok_list $ok_list | uniq -u > $bad_list

        # pdsh will delete the domain name of a server, so use grep -v -f, but if a server's name is prefix of another, this method will get wrong result
        grep -v $raw_machine_list -f $ok_list > $bad_list
        still_bad_count=$(wc -l $bad_list)
        echo "************** still bad : $still_bad_count *******************"
        machine_list=$bad_list
        bak_count=$ok_count
        ok_count=$(sort $ok_list | uniq | wc -l | awk '{print $1}')

        if [ $ok_count -eq $bak_count ]
        then
                ((same_err_count = $same_err_count + 1))
        else
                same_err_count=0
        fi

        if [ $same_err_count -ge 2 ]
        then
                exit 2
        fi
done

if [ $ok_count -eq $all_count ]
then
        echo "************** ALL OK ***************"
fi
