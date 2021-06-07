#!/bin/bash
ur=readlog

/usr/sbin/useradd  $ur
echo "admaster54322"|passwd  --stdin $ur
echo "$ur   ALL=(ALL)     NOPASSWD: /bin/cat ,/bin/ls" >> /etc/sudoers
