#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;

my $dir=$ARGV[0];

sub report{
        my $t = 1024 * 1024 * 1024 * 1024;
        my ($name, $val) = @_;
#       print "$name : $val\n";
        my $cmd = " $name : $val ";
        if ($val > $t) {
                $val = $val / $t;
                $cmd = " $name : $val T";
        }
        print $cmd, "\n";
}


############## main #######################
#my $yestoday_cmd = 'date +%F -d"-0 day"';
my $yestoday_cmd = 'date +%F -d"-1 day"';
my $yestoday = qx/$yestoday_cmd/;
chomp $yestoday;

my $workfiles = "$dir/*";

########### main #############

my %summary = ();

open KK, "cat $workfiles 2>/dev/null|";

while (<KK>) {
        chomp;
        if (/^\s*(\S+)\s+(\d+)/) {
                my ($key, $val) = ($1, $2);
                $summary{$key} += $val;
        }
}

for (keys %summary) {
        report  $_, $summary{$_};
}
