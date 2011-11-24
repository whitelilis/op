#!/usr/bin/env perl
use strict;
use warnings;

my $file = $ARGV[0];
my $start = $ARGV[1];
my $end = $ARGV[2];

my %summary = ();

open KK, "<", $file;

print "内存占用 500M 以上的进程\n";
print "内存占用(kB)   进程名\n";


while (<KK>) {
        chomp;
        if (/$start/../$end/) {
                next if /$start/ or /$end/;
                #print $_ . "\n";
                my @tmp = split /\s+|\//;
                if ($tmp[5] =~ /\d+/  && $tmp[5] > 500000){
                        if ($tmp[-2] =~ /^(attempt_\d+_\d+_\S)_.*/) {
                                $summary{$1} += $tmp[5];
                        }
                        print "$tmp[5]  $tmp[-2]  $tmp[-1]\n";
                }
        }
}

my $sp = '-' x 20;

print "$sp summary $sp\n";

for (keys %summary) {
        print "$_ :" .  ($summary{$_}/1024/1024) . " G\n";
}
