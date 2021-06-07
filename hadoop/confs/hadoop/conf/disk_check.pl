#!/usr/bin/env perl

use strict;
#use warnings;

my %disk_hash = ();
my %mount_hash = ();
my $err_flag = "ERROR";
my $ok_flag = "OK";

my $main_ip = "";

open NC, "LANG=C /sbin/ifconfig |";

while (<NC>){
        chomp;
        if (/inet addr:(\S+)/){
                if (/inet addr:127.0.0.1/){
                        next;
                }else{
                        $main_ip = $main_ip . $1;
                }
        }
}

close NC;

open DMSG, "dmesg |";

while (<DMSG>) {
        chomp;
        if (/fs error \(device (\w+)\)/
            || /fs \((\w+)\): previous I\/O error/
            || /I\/O error detected when updating journal superblock for (\w+)/
	    || /end_request: critical target error, dev (\w+)/
            #|| /end_request: I\/O error, dev (\w+), sector/  #  a sector error, not very seriours
            || /(\w+): I\/O error 1/) {
		my $dev = $1;
		$dev =~ s/\d+//;
		$dev =~ s/\/dev\///;
		$disk_hash{$dev} = $err_flag;
#    print "$1 is error\n";
	}
	if (/\((\w+)\): mounted filesystem with ordered data mode/) {
		my $dev = $1;
		$dev =~ s/\d+//;
		$dev =~ s/\/dev\///;
		$disk_hash{$dev} = $ok_flag;
#    print "$1 is ok\n";
	}
}

close DMSG;


open MT, "LANG=C /bin/mount |";
while (<MT>){
	chomp;
	split;
	my $dev = $_[0];
	$dev =~ s/\d+//;
	$dev =~ s/\/dev\///;
	$mount_hash{$dev} = "1";
#print $dev . "\n";
}
close MT;



my $ret = 0;
for my $key (sort keys %disk_hash) {
	my $clear_key = $key;
	$clear_key =~ s/\d+//;
	if($disk_hash{$key} eq $err_flag  && $mount_hash{$clear_key}){
		$ret = 1;
#my $cmd = $main_ip . " " . $key . " " . $disk_hash{$key};
		my $cmd = $disk_hash{$key} . " " . $key;
		print $cmd . "\n";
	}
}



exit $ret;
