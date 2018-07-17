#!/bin/bash
cwd=$(cd $(dirname $0); pwd)
cd  $cwd
source /etc/profile

bak_dir=user_bak/$(hostname)

mkdir -p $bak_dir

awk -F: '($3>=500) && ($3!=65534) ' /etc/passwd > $bak_dir/passwd
awk -F: '($3>=500) && ($3!=65534) ' /etc/group > $bak_dir/group
awk -F: '($3>=500) && ($3!=65534) {print $1} ' /etc/passwd|tee -|egrep -f - /etc/shadow > $bak_dir/shadow


echo "bak ok to $bak_dir"
