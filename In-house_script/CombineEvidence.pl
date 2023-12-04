#!/usr/bin/perl -w
use strict;
use warnings;

my $direct_evidence = $ARGV[0];

open IN,"<$direct_evidence";

my %info = ();

while(my $line = <IN>)
{
	chomp $line;
	my @arr = split/\t/,$line;
	if($arr[2] =~ /KPC/)
	{
		$info{$arr[1]}{$arr[4]}{'KPC'}{'Direct'} = $arr[-1];
	}
	if($arr[2] =~ /NDM/)
        {
                $info{$arr[1]}{$arr[4]}{'NDM'}{'Direct'} = $arr[-1];
        }
	if($arr[2] =~ /OXA/)
        {
                $info{$arr[1]}{$arr[4]}{'OXA'}{'Direct'} = $arr[-1];
        }
	if($arr[2] =~ /CTX/)
        {
                $info{$arr[1]}{$arr[4]}{'CTX'}{'Direct'} = $arr[-1];
        }

}

my $plasmid_evidence = $ARGV[1];
open IN,"<$plasmid_evidence";
while(my $line = <IN>)
{
        chomp $line;
        my @arr = split/\t/,$line;
        if($arr[2] =~ /KPC/)
        {
                $info{$arr[1]}{$arr[4]}{'KPC'}{'Plasmid'} = $arr[-1];
        }
        if($arr[2] =~ /NDM/)
        {
                $info{$arr[1]}{$arr[4]}{'NDM'}{'Plasmid'} = $arr[-1];
        }
        if($arr[2] =~ /OXA/)
        {
                $info{$arr[1]}{$arr[4]}{'OXA'}{'Plasmid'} = $arr[-1];
        }
	if($arr[2] =~ /CTX/)
        {
                $info{$arr[1]}{$arr[4]}{'CTX'}{'Plasmid'} = $arr[-1];
        }
}
my $coverage_evidence = $ARGV[2];
open IN,"<$coverage_evidence";
while(my $line = <IN>)
{
        chomp $line;
        my @arr = split/\t/,$line;
        if($arr[2] =~ /KPC/)
        {
                $info{$arr[1]}{$arr[4]}{'KPC'}{'Coverage'} = $arr[-1];
        }
        if($arr[2] =~ /NDM/)
        {
                $info{$arr[1]}{$arr[4]}{'NDM'}{'Coverage'} = $arr[-1];
        }
        if($arr[2] =~ /OXA/)
        {
                $info{$arr[1]}{$arr[4]}{'OXA'}{'Coverage'} = $arr[-1];
        }
	if($arr[2] =~ /CTX/)
        {
                $info{$arr[1]}{$arr[4]}{'CTX'}{'Coverage'} = $arr[-1];
        }
}
my %out = ();
my %outInfo = ();
for my $k(keys %info)
{
	$k =~ /(.+)__.+/;
	my $id = $1;
	for my $k1(keys %{$info{$k}})
	{
		for my $k2(keys %{$info{$k}{$k1}})
		{
			my $res = 0;
			if($info{$k}{$k1}{$k2}{'Direct'} == 1 or ($info{$k}{$k1}{$k2}{'Coverage'} >= 0.05 and $info{$k}{$k1}{$k2}{'Plasmid'} >= 1))
			{
				$res = 1;
			}
			if(not exists $out{$id}{$k2} or (exists $out{$id}{$k2} and $out{$id}{$k2} != 1))
			{
				$out{$id}{$k2} = $res;
				@{$outInfo{$id}{$k2}} = ($info{$k}{$k1}{$k2}{'Direct'},$info{$k}{$k1}{$k2}{'Coverage'},$info{$k}{$k1}{$k2}{'Plasmid'});
			}

		}
	}
}


my @tmp = ("KPC","NDM","OXA","CTX");
for my $k(keys %out)
{
	print $k,"\t";
	for my $bla(@tmp)
	{
		if(exists $out{$k}{$bla})
		{
			print join("\t",@{$outInfo{$k}{$bla}}),"\t",$out{$k}{$bla},"\t";	
		}
		else
		{
			print "NA\tNA\tNA\tNA\t";
		}
		
	}
	print "\n";
}








