#!/usr/bin/env perl
use strict;
use warnings;

my $blacklist_file = "./blacklist";
my $ip_host_file = "/etc/hosts";
my $log_file = "./all_check_log";
my $result_file = "/tmp/all_check_result";
my $hadoop = "/opt/hadoop/program/bin/hadoop";


my @scripts = qw/ping-ok-p ssh-not-hang-p sshd-ok-p ssh-right-ok-p sys-not-ro-p ps-not-hang-p datanode-process-exist-p stop-datanode-not-hang-p start-datanode-not-hang-p/;
my %script_failed_message = (
	"ping-ok-p"                       => "        以下机器 ping 不通                  ",
	"ssh-not-hang-p"                  => "        以下机器 ssh hang 住                ",
	"sshd-ok-p"                       => "        以下机器 sshd 异常                  ",
	"ssh-right-ok-p"                  => "        以下机器没有 ssh 权限               ",
	"sys-not-ro-p"                    => "  以下机器系统分区只读,请修复，或重装系统   ",
	"ps-not-hang-p"                   => "        以下机器 ps 会 hang 住              ",
	"datanode-process-exist-p"        => "   以下机器 datanode 进程启动失败           ",
	"stop-datanode-not-hang-p"        => " 以下机器 stop datanode 会 hang 住          ",
	"start-datanode-not-hang-p"       => "以下机器 start datanode 会 hang 住          ",
);


my %blacklist = ();

# generate blacklist
if (-e "$blacklist_file"){
	open BL, "<", "$blacklist_file";
	while (<BL>){
		chomp;
		$blacklist{$_} = 1;
	}
	close BL;
}

# get time now
sub now{
	my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst)=localtime;

	return ($year + 1900) . "_" .  ($mon + 1) . "_" . $mday . "_" . $hour . ":" . $min . ":" . $sec;
}


# to use shell script 
sub fake_sh{
	my $script = shift;
	my $machine = shift;
	my $cmd = "./$script $machine";
	my $ret = qx/$cmd/;
	chomp $ret;
	return ($ret eq 'Y');
}



# read ip to name rules
my %name_hash = ();
open H, "<", "$ip_host_file";
while (<H>){
	chomp;
	my @tmp = split /\s+/, $_;
#print $tmp[0], "\n";
	$name_hash{$tmp[0]} = $tmp[1];
}
close H;



# for log
open LOG, ">>", "$log_file";
select LOG;

my $check_single_cmd = 'ps ux | grep -v grep | grep -v " vim "| grep disk_from_report.pl';
my @csc = qx/$check_single_cmd/;

if(@csc > 1){
	print now, "  last running not exit!!!\n";
	exit -1;
}


print "---------------diskcheck start at ", now, "-----------------\n";

my $cmd = "$hadoop dfsadmin -report";
my @report = qx/$cmd/;

my $machine = undef;
my $space = undef;

my @first = ();

for (@report) {
	chomp;
	if (/^Name\D+(.*):50010/) {
		$machine = $1;
	}
	if (/Configured Capacity\D+(.*)/) {
		$space = $1;
		if ($space !~ /21644341633024/ && $machine){
			next if $blacklist{$machine};
			print $machine, "##, ", $space, "\n";
			push @first, $machine;
		}
	}
}

for (@first){
	chomp;
	my $reset_cmd = "./reset_datanode.sh $_ &";
	print now, " ", $reset_cmd, "\n";
#qx/$reset_cmd/;
	system "$reset_cmd";
}

my $sleep_time = @first * 25;

print "start sleeping for $sleep_time second\n";
sleep $sleep_time;
#sleep 20;

print "sleep finished\n";

my %maybe = ();
for (@first){
	$maybe{$_} = 1;
}

@report = qx/$cmd/;

$machine = undef;
$space = undef;

my @disk = ();

my %other = ();



# init store db
for my $s (@scripts){
	my @temp = ();
	$other{$s} = \@temp;
}


for (@report) {
	chomp;
	if (/^Name\D+(.*):50010/) {
		$machine = $1;
	}
	if (/Configured Capacity\D+(.*)/) {
		$space = $1;
		if ($space !~ /21644341633024/ && $machine && $maybe{$machine}){
			next if $blacklist{$machine};
			if($space =~ /0 KB/){ 
# do many judgement
				for my $script (@scripts){
					unless(fake_sh $script . ".sh", $machine){
						push @{$other{$script}}, $machine;
						last; # last script, next machine;
					}
				}
			}else{
				push @disk, $machine;
			}
		}
	}
}

print now, " check finished\n";
close LOG;


sub pp{
	my ($message, $arr_ref) = @_;
	if(@{$arr_ref}){
		print "\n$message\n";
		for(@{$arr_ref}){
			print $name_hash{$_}, " ", $_, "\n";
		}
	}
}


# for system administrator
my $time_result_file =  $result_file . "_" . now;

open SHOW, ">", "$time_result_file";
select SHOW;
print "--------------", now, "   diskcheck 结果---------------\n\n";


for my $sr (@scripts){
	pp "=== $script_failed_message{$sr} ===", $other{$sr};
}

#   ===    以下机器 datanode 进程启动失败   ===
pp "====         以下机器硬盘坏了   ===========", \@disk;



close SHOW;

my $cp_cmd = "cp $time_result_file $result_file";

qx/$cp_cmd/;


