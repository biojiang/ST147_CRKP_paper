#!/usr/bin/perl -w
use strict;
use warnings;

my $self_target_spacer_blast_dir = $ARGV[0];

my $mismatch = 0;
my %list = (
	'KPC-2'=>1,'KPC-3'=>1,
	'NDM-1'=>1,'NDM-4'=>1,'NDM-5'=>1,'NDM-7'=>1,'NDM-9'=>1,
	'OXA-48'=>1,'OXA-162'=>1,'OXA-181'=>1,'OXA-204'=>1,'OXA-232'=>1,'OXA-244'=>1
);

open IN,"<all.ST147.resfinder";
<IN>;
my %directTarget = ();
while(my $line = <IN>)
{
	#print $line;
	chomp $line;
	my @arr = split/\t/,$line;
	$arr[4] =~ s/_\d//g;
	$arr[4] =~ s/bla//g;
	if(exists $list{$arr[4]} or $arr[4] =~ /CTX-M/)
	{
		$arr[1] =~ /(.+)__/;
                my $id = $1;
                open BLAST,"<$self_target_spacer_blast_dir/$id.blast";
                while(my $line1 = <BLAST>)
                {

                        chomp $line1;
                        my @ele = split/\t/,$line1;
                        if($ele[4]+$ele[5] <= $mismatch)
                        {
                                #$directTarget{$id}{$arr[4]} = 0;
				my $directSupport = 0;
                        	if($arr[1] eq $ele[1])
                        	{
                                	$directSupport = 1;
                        	}
                        	print $id,"\t",$arr[1],"\t",$arr[4],"\t",$ele[0],"\t",$ele[1],"\t",$directSupport,"\n";
			}

                }

	}

}
