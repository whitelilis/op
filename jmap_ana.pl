#!/usr/bin/env perl


# anaylyze mulity jmap -histo result, to detect which object's memory grow much
# # useage : cat jmap_file1 jmapfile2 ... | ./jmap_ana.pl
#
use strict;
use warnings;

use Data::Dumper;
use Statistics::LineFit;
use GD::Graph::lines;
use Getopt::Std;


my $recordFile = "jmap_test.r";
my $topNum = 6;
my %h = ();

my %opts = ();
getopts('htn:m:', \%opts);

#warn Dumper(\%opts);


sub help{
        print "anaylyze mulity jmap -histo result, to detect which object's memory grow much\n";
        print "useage : cat jmap_file1 jmapfile2 ... | ./jmap_ana.pl\n";
        print "options : -h  for this help\n";
        print "          -t  for analyze Total, default not\n";
        print "          -n <name> for output filename, default jmap.gif\n";
        exit 0;
}


sub singleFt{
        my $a_r = shift;
        my @arr = @{$a_r};

        my @dum = (0,0);
        return \@dum if @arr < 5;

        my @x = 0..$#arr;

        my $lineFit = Statistics::LineFit->new();
        $lineFit->setData (\@x, \@arr) or die "Invalid data";
        my @r = $lineFit->coefficients();
        return \@r;
}


sub ftCompator{
        my ($a, $b) = @_;
        my @t1 = @{singleFt $h{$a}};
        my @t2 = @{singleFt $h{$b}};
        return $t2[1] <=> $t1[1];
}


sub arr_same_length{
        my $a_r = shift;
        my $max_len = 0;

        for ( @{$a_r} ) {
                $max_len = @{$_} if @{$_} > $max_len;
        }

        #warn "max leng is $max_len\n";

        for ( @{$a_r} ) {
                my $more = $max_len -  @{$_};
                if ($more) {
                        my @tmp = @{$_};
                        for ( 1..$more ) {
                                unshift @tmp, 0;
                        }
                        $_ = \@tmp;
                }
        }
}



sub sim_draw{
        my ($data_r, $legend_r, $name) = @_;
        arr_same_length($data_r);
        my @data = @{$data_r};

        my $max_x = @{$data[0]};

        unshift @data, [1..$max_x];

        my $graph = GD::Graph::lines->new(1800, 1000);

        $graph->set(
                x_label           => 'Count',
                y_label           => 'Mem(b)',
                title             => 'Memery',
                transparent      => 0,
                x_label_skip => 50,


            ) or die $graph->error;

        $graph->set_legend_font( '/usr/share/fonts/wqy-zenhei/wqy-zenhei.ttc', 20);
        $graph->set_legend(@{$legend_r});
        open IMG, ">", $name or die $!;
        print IMG $graph->plot(\@data)->gif;
        close IMG;


        for ( 1 .. $#data) {
                my @leg = ($legend_r->[$_ - 1]);

                my $graph = GD::Graph::lines->new(1800, 1000);

                $graph->set(
                        x_label           => 'Count',
                        y_label           => 'Mem(b)',
                        title             => 'Memery',
                        transparent      => 0,
                        x_label_skip => 50,


                    ) or die $graph->error;

                $graph->set_legend_font( '/usr/share/fonts/wqy-zenhei/wqy-zenhei.ttc', 20);
                $graph->set_legend(@leg);
                open IMG, ">", $leg[0] . ".gif" or die $!;
                print IMG $graph->plot([$data[0], $data[$_]])->gif;
                close IMG;
        }
}

help if $opts{h};


while (<>){
        chomp;
        my ($no, $count, $byte, $type) = split;
        next unless $no && ($no =~ /\d+:/ or $no =~ /Total/);
        $type = 'Total' if $no =~ /Total/;

        next if $no =~ /Total/ && ! $opts{t};

        if (! $h{$type}){
                my @tmp = ();
                $h{$type} = \@tmp;
        }
        push @{$h{$type}}, $byte;
}


my @sks = (sort {ftCompator $a, $b} (keys %h))[0 .. $topNum];


for (@sks) {
        print $_, " : ";
        print join ", ", @{singleFt $h{$_}};
        print "\n";
}
print "=" x 60;

print "\nRecorde detail is at $recordFile\n";

open KK, ">", $recordFile;

select KK;

for ( @sks ) {
        print $_, " : ";
        print join ", ", @{$h{$_}};
        print "\n";
}


my @draw_data = ();
for ( @sks ) {
        push @draw_data, $h{$_};
}

$opts{n} = 'jmap.gif' unless $opts{n};


sim_draw \@draw_data, \@sks, $opts{n};





__DATA__

 num     #instances         #bytes  class name
----------------------------------------------
   1:      26705309     2632486680  [Ljava.lang.Object;
........
   7:      52315572      837049152  java.lang.Object
   8:       5634714      444724368  [Lorg.apache.hadoop.hdfs.server.namenode.BlocksMap$BlockInfo;
   9:       5812609      418507848  sun.nio.ch.SocketAdaptor
  10:       5846787      374194368  java.lang.ref.Finalizer
  11:       5138015      369937080  org.apache.hadoop.hdfs.server.namenode.INodeFile
  12:       5812611      279005328  [Ljava.nio.channels.SelectionKey;
........
Total     219195770    13590126928

