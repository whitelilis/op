#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use FindBin;



my $result_dir = $FindBin::Bin . "/results";

my @all_result = ();

sub main{

        my %summary = (
                       exit_no => 0, # default exit_no
                      );
        open KK, "cat $result_dir/*.r 2>/dev/null |";
        while (<KK>) {
                chomp;
		next if /^\s*$/;
                #print $_, "\n";
                my %tmp = ();
		/(\d+)\s+(.*)/;
                ($tmp{exit_no}, $tmp{msg}) = ($1, $2);
                push @all_result, \%tmp;
                # print Dumper(\@all_result);
        }
        close KK;

        my @s_results = reverse (sort {$a->{exit_no} <=> $b->{exit_no}} @all_result);
        if (@s_results) {
                $summary{exit_no} = $s_results[0]->{exit_no};
        }
        if ($summary{exit_no} == 0) { # all ok, no abnormal message
                $summary{msg} = "all ok";
        } else {
                $summary{msg} = join ";", (map {$_->{msg}} (grep {$_->{exit_no} != 0} @s_results));
        }
        #print Dumper(\%summary);
        print $summary{msg}, "\n";
        exit $summary{exit_no};
}

main;



