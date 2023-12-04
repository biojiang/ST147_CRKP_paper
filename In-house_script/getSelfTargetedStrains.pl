#!/usr/bin/perl -w
use strict;
use warnings;

my $blast_dir = $ARGV[1];
my $mismatch = 0;
my %self = ();
open IN,"<$ARGV[0]";
<IN>;
while(my $line = <IN>)
{
	chomp $line;
	my @arr = split/\t/,$line;
	if(not -e "self_blast/$arr[0].blast")
	{
		print $arr[0];
		exit;
	}
	open BLAST,"<self_blast/$arr[0].blast";
	$self{$arr[0]} = 0;
        while(my $line1 = <BLAST>)
        {
            chomp $line1;
            my @ele = split/\t/,$line1;
            if($ele[4]+$ele[5] > $mismatch)
            {
                 next;
            }
            else
            {
		 $self{$arr[0]} = 1;
	    }
    	}
	print $arr[0],"\t",$self{$arr[0]},"\n";

}
