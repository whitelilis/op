#!/usr/bin/env perl
use strict;

my $log_path = $ARGV[0];

my $main_ip = "";
open NC, "LANG=C /sbin/ifconfig |";
while (<NC>){
        chomp;
        if (/inet addr:(\S+)/){
                if (/inet addr:127.0.0.1/){
                        next;
                }else{
                        $main_ip = $1;
                        last;
                }
        }
}
close NC;

open LOG, "tail -F $log_path 2>/dev/null |" or die $!;

while( <LOG> ) {
        chomp;
        next unless /\S/;
        split ',';
        printf("%s\n", join(',', $_[14], $_[20], $_[21], $_[22], $_[23], $main_ip, $_[17]));
}
