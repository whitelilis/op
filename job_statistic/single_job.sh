#!/bin/sh

job_id=$1

ddd=$(date +%F)
cwd=$(dirname $0)
job_daily_dir="$cwd/job_file/$ddd"
job_file="$job_daily_dir/$job_id"

statistic_daily_dir="$cwd/job_statistic/$ddd"
statistic_file="$statistic_daily_dir/$job_id"


sim_get(){
    job_id=$1
    links -dump "http://10.100.20.2:50030/jobdetails.jsp?jobid=$job_id"
}

static(){
    jobfile=$1
    grep "Hadoop job" $jobfile | awk '{print "job_id " $2}'
    grep  "User:" $jobfile | awk -F":" '{print  "user " $2}'
    grep  "Job Name:" $jobfile | awk -F":" '{print  "job_name " $2}'
    grep  "Status:" $jobfile | awk -F":" '{print  "status " $2}'
    grep "| map" $jobfile | awk -F"[|/]" '{print "maps " $4 "\nmap_faild " $(NF-2) "\nmap_killed " $(NF-1)}'
    grep  "|reduce" $jobfile | awk -F"[|/]" '{print "reduces " $4 "\nreduce_faild " $(NF-2) "\nreduce_killed " $(NF-1)}'
    grep "|MapReduce" $jobfile -B1 -A1 | grep -v "|MapReduce" | awk -F'|' '{print tolower($3) " " $(NF-1)}'
    grep "|Reduce shuffle" $jobfile | awk -F'|' '{print  "shuffle " $(NF-1)}'
    grep "FILE_BYTES_READ" $jobfile | awk -F'|' '{print "file_bytes_read " $(NF-1)}' 
    grep "HDFS_BYTES_READ" $jobfile | awk -F'|' '{print "hdfs_bytes_read " $(NF-1)}' 
    grep "FILE_BYTES_WRITTEN" $jobfile | awk -F'|' '{print "file_bytes_written " $(NF-1)}' 
    grep "HDFS_BYTES_WRITTEN" $jobfile | awk -F'|' '{print "hdfs_bytes_written " $(NF-1)}' 
}

main(){
        mkdir -p $job_daily_dir $statistic_daily_dir
        sim_get $job_id > $job_file 2>/dev/null
        static $job_file | sed 's/,//g' > $statistic_file 2>/dev/null
}

main
