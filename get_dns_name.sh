#!/bin/bash
ip=$(ping -c1 -w3 $1 | grep PING | awk '{print $3}' | sed -e 's/[():]//g')

host=$(nslookup $ip | grep name | awk '{print $4}' | sed -e 's/\.//')

dnsname=$(nslookup $host | grep Name | awk '{print $2}')

echo $dnsname
