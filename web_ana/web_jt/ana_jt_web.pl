#!/usr/bin/env perl
use strict;
use warnings;


my $file = $ARGV[0];

open KK, "<", $file;

sub report{
	my ($name, $val) = @_;
#	print "$name : $val\n";
	my $cmd = "gmetric -n $name -v $val -t float";
#	print $cmd, "\n";
	qx/$cmd/;
}


while (<KK>){
	if (/Cluster Summary/../^\s*[-]+\s*$/){
		chomp;
		next unless /^\s*\|\s*([0-9.]+)\s*\|\s*([0-9.]+)\s*\|\s*([0-9.]+)\s*\|\s*([0-9.]+)\s*\|\s*([0-9.]+)\s*\|\s*([0-9.]+)\s*\|\s*([0-9.]+)\s*\|\s*([0-9.]+)\s*\|/;
		report "run_map", $1;
		report "run_red", $2;
		report "all_submit", $3;
		report "tt_num", $4;
		report "map_cap", $5;
		report "red_cap", $6;
		report "black_list", $8;
	}
	#print if /Scheduling Information/../^\s*[-]+\s*$/;
}


__DATA__
 |1403|2075   |8282       |489  |5868    |2445     |17.00     |6          |
