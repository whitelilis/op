#!/bin/bash

file=$1
key=$2
value=$3

ts=$(date +%s)

sed -i.bak_$ts -e "/$key/{n; s@>.*<@>$value<@}" /etc/hadoop/conf/$file
