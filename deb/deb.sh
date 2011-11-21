#!/bin/sh

#set -x
machines=$1
cmd=$2
ft=$(dirname $0)"/ft"

for f in $(cat $machines) 
do
	{
		$ft "ssh liuzhe@$f 'echo $f: \$($cmd)'"
		if [ $? -eq 137 ]
		then
			echo "$f: FTKILLED!"
		fi
	} &
done
wait

