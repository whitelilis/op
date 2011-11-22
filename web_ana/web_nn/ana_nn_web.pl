#!/usr/bin/env perl
use strict;
use warnings;


my $file = $ARGV[0];

open KK, "<", $file;

sub report{
	my ($name, $val, $uni) = @_;
#	print "$name : $val\n";
	my $cmd = "gmetric -n \"$name\" -v $val -t float -u \"$uni\"";
#	print $cmd, "\n";
	qx/$cmd/;

}


while (<KK>){
	if (/Configured Capacity/../^\s*[-]+\s*$/){
		chomp;
		next unless /\s*([^:]+)\s*:\s*([0-9.]+)\s*(\S*)\s*/;
		my ($name, $value, $uni) = ($1, $2, $3);
		$name =~ s/\s*$//;
		report $name, $value, $uni;	
		#print "1 is #$1# 2 is #$2# 3 is #$3#"  . "\n";
	}
	#print if /Scheduling Information/../^\s*[-]+\s*$/;
}


__DATA__
 |1403|2075   |8282       |489  |5868    |2445     |17.00     |6          |
