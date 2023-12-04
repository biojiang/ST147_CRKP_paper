#!/usr/bin/perl -w
use strict;
use warnings;
use Set::Scalar;

my $mismatch = 0;
my %list = (
        'KPC-2'=>1,'KPC-3'=>1,
        'NDM-1'=>1,'NDM-4'=>1,'NDM-5'=>1,'NDM-7'=>1,'NDM-9'=>1,
        'OXA-48'=>1,'OXA-162'=>1,'OXA-181'=>1,'OXA-204'=>1,'OXA-232'=>1,'OXA-244'=>1
);

my $self_blast_dir = $ARGV[0];
my $map_dir = $ARGV[1];

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
                open BLAST,"<$self_blast_dir/$id.blast";
                while(my $line1 = <BLAST>)
		{
			chomp $line1;
                        my @ele = split/\t/,$line1;
                        if($ele[4]+$ele[5] <= $mismatch)
                        {

				my $plasmidSupport = &plsSupport($id,$ele[1],$arr[1]);
				print $id,"\t",$arr[1],"\t",$arr[4],"\t",$ele[0],"\t",$ele[1],"\t",$plasmidSupport,"\n";
			}
		}
	}

}



sub plsSupport()
{
	my $id = shift;
	my $ctg1 = shift;
	my $ctg2 = shift;
	my $cutoff = 0.8;
	my @set1 = ();
	my @set2 = ();
	open MAP,"<$map_dir/$id.plasmid.map";
	while(my $line2 = <MAP>)
	{
		chomp $line2;
		my @arr = split/\t/,$line2;
		if($arr[10]/$arr[1] >= $cutoff)
		{
			if($arr[0] eq $ctg1)
			{
				push @set1,$arr[6];
			}
			elsif($arr[0] eq $ctg2)
			{
				push @set2,$arr[6];
			}
		}

	}
	my $s1 = Set::Scalar->new(@set1);
        my $s2 = Set::Scalar->new(@set2);
	my $intersection = $s1 * $s2;
	return $intersection->size;



}
