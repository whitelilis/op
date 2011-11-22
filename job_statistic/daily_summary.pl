#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;


sub report{
        my $t = 1024 * 1024 * 1024 * 1024;
        my ($name, $val) = @_;
#       print "$name : $val\n";
        my $cmd = "gmetric -n $name -v $val -t double";
        if ($val > $t) {
                $val = $val / $t;
                $cmd = "gmetric -n $name -v $val -t double -u 'T'";
        }
#        print $cmd, "\n";
        qx/$cmd/;
}


############## main #######################
#my $yestoday_cmd = 'date +%F -d"-0 day"';
my $yestoday_cmd = 'date +%F -d"-1 day"';
my $yestoday = qx/$yestoday_cmd/;
chomp $yestoday;

my $workfiles = $FindBin::Bin . "/job_statistic/$yestoday/" . '*';

########### main #############

my %summary = ();

open KK, "cat $workfiles 2>/dev/null|";

while (<KK>) {
        chomp;
        if (/^\s*(\S+)\s+(\d+)/) {
                my ($key, $val) = ($1, $2);
                $summary{$key} += $val;
        }
	if(/^status\s+(\S+)/){
		$summary{"job_" . $1} += 1;
		$summary{"job_all"} += 1;
	}
}

for (keys %summary) {
        report $_, $summary{$_};
}
