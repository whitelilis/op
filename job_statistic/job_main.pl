#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use threads;

my $wait_time = 30; # wait seconds before real get

my $monitoer_file = $ARGV[0];


sub gen_single{
        my $job_id = shift;
	sleep $wait_time;
        my $cmd = $FindBin::Bin . "/single_job.sh $job_id";
        qx/$cmd/;
}




##################### main ######################
open KK, "tail --follow=name $monitoer_file |";

while (<KK>) {
        chomp;
        if (/(job[0-9_]+)\s*has completed successfully/  || /Killing job '(job[0-9_]+)'/ ) {
                my $job = $1;
                #print "$job\n";
		my $t = threads->new(\&gen_single, $job);
		$t->yield;
        }
}
