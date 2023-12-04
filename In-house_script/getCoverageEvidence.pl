#!/usr/bin/perl -w
use strict;
use warnings;
use Statistics::TTest;
use List::Util qw/shuffle/;
use threads;
use Thread::Semaphore;
use AutoLoader;

my $max_threads = 60;
my $semaphore = new Thread::Semaphore($max_threads);
my @queue = ();
my %finalRes = ();

my $bed_dir = $ARGV[0];
my $repeat_dir = $ARGV[1];
my $annotation_dir = $ARGV[2];
my $self_blast_dir = $ARGV[3];




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
                open BLAST,"<$self_blast_dir/$id.blast";
                while(my $line1 = <BLAST>)
                {

                        chomp $line1;
                        my @ele = split/\t/,$line1;
                        if($ele[4]+$ele[5] <= $mismatch)
                        {
				my @input = ($id,$arr[1],$arr[4],$ele[0],$ele[1]);
				push @queue,\@input;
			}


		}
	}

}

my $j = 0;
while(1)
{
        if($j > $#queue)
        {
                last;
        }
        else
        {
		$semaphore->down();
		push @{$queue[$j]},$j;
		my $thread = threads->new(\&runner,$j);
		$thread->detach();
                $j++;
        }
}


&waitquit;
system("cat *.tmp > IE_self_targeted_spacers.carb.Coverage.evidence");
system("rm *.tmp");

sub waitquit
{
        my $num = 0;
        while($num<$max_threads)
        {
                $semaphore->down();
                $num++;
        }
}




sub runner()
{
	my $num = shift;
	my $info = $queue[$num];
	my $id = ${$info}[0];
	my $info1 = ${$info}[1];
	my $info2 = ${$info}[2];
	my $info3 = ${$info}[3];
	my $info4 = ${$info}[4];
	my $coverageSupport = &testCoverage($id,$info4,$info1);
	my $out = $id."\t".$info1."\t".$info2."\t".$info3."\t".$info4."\t".$coverageSupport."\n";
	open OUT,">${$info}[5].tmp";
	print OUT $out;
	close OUT;
	$semaphore->up();
}





sub testCoverage()
{
	my $id = shift;
	my $ctg1 = shift;
	my $ctg2 = shift;
	my $cov_file = "$bed_dir/$id.cov.bed";#"./46564.cov.bed";
	my $anno_file = "$annotation_dir/$id/$id.gff";#"./46564_anno/PROKKA_04052023.gff";
	my $repeat_file = "$repeat_dir/$id/AnnotationReport.info";#"./repeat/AnnotationReport.info";
	if(not -e $cov_file)
	{
		return -1;
	}
	my %cov = ();

	my %repeat_region = ();
	open IN2,"<$repeat_file";
	<IN2>;
	while(my $line = <IN2>)
	{
        	chomp $line;
        	$line =~ s/^\s+//;
        	my @arr = split/\s+/,$line;
        	#print $arr[3];
        	$arr[3] =~ /NODE_(.+?)_Length/;#NODE_12_Length_165336
        	#print $1;
        	#exit;
        	my $id = $1 +1;
		if(exists $repeat_region{$id})
        	{
                	push @{$repeat_region{$id}},{"start"=>$arr[4],"end"=>$arr[5]};
        	}
       		else
        	{
                	@{$repeat_region{$id}} = ({"start"=>$arr[4],"end"=>$arr[5]});
        	}

	}
	close IN2;
	open IN2,"<$cov_file";
	while(my $line = <IN2>)
	{
        	chomp $line;
        	my @arr = split/\t/,$line;
        	$cov{$arr[0]}{$arr[1]} = $arr[2];
	}
	close IN2;
	my %ctg_cov = ();
	open IN2,"<$anno_file";

	while(my $line = <IN2>)
	{
        	if($line =~ /^#/)
        	{
                	next;
        	}
        	else
       	 	{
                	chomp $line;
                	my @arr = split/\t/,$line;
                	if($arr[0] eq $ctg1 or $arr[0] eq $ctg2)
                	{
                        	my @arr = split/\t/,$line;#46562__1     Prodigal:002006 CDS     173498  174241
                        	if($arr[-1] =~ /ISfinder/)
                        	{
                                	next;
                        	}
                        	$arr[0] =~ /.+_(.+)$/;
                        	my $id = $1;
                        	if(exists $repeat_region{$id})
                        	{
                                	map{if(($arr[3] >= $_->{"start"} and $arr[3] <= $_->{"end"}) or ($arr[3] >= $_->{"start"} and $arr[3] <= $_->{"end"})){next;}}@{$repeat_region{$id}};
                        	}
				my $sum = 0;
				my $len = 0;
                        	for(my $i=$arr[3];$i<=$arr[4];$i++)
                        	{
					if(exists $cov{$arr[0]}{$i})
                                        {
                                                $sum += $cov{$arr[0]}{$i};
                                                $len ++;
                                        }
                        	}
				if($len != 0)
				{
					my $ave_cov = $sum/$len;
					if(exists $ctg_cov{$arr[0]})
					{
						push @{$ctg_cov{$arr[0]}},$ave_cov;
					}
					else
					{
						@{$ctg_cov{$arr[0]}} = ($ave_cov);
					}
				}
                	}
        	}
	}
	close IN2;
	my $res_p = 1;
        my $ttest = new Statistics::TTest;
        if((exists $ctg_cov{$ctg1} and scalar @{$ctg_cov{$ctg1}} >= 3) and (exists $ctg_cov{$ctg2} and scalar @{$ctg_cov{$ctg2}} >= 3))
        {
		#print $ctg1,"\t",$ctg2,"\n";
		#exit;
		my $sample1 = \@{$ctg_cov{$ctg1}};
		my $sample2 = \@{$ctg_cov{$ctg2}};
		if(scalar @{$sample1} > 200)
		{
			$sample1 = &subsample(@{$ctg_cov{$ctg1}});
		}
		if(scalar @{$sample2} > 200)
                {
                        $sample2 = &subsample(@{$ctg_cov{$ctg2}});
                }
		$ttest->load_data($sample1,$sample2);
		$res_p = $ttest->{t_prob};
        }
	return $res_p;

}



sub subsample()
{
	my @arr = @_;
	my @samples = ();
	for(my $i=0;$i<200;$i++)
	{
		@arr = shuffle @arr;
		my $item = shift @arr;
		push @samples,$item;
	}
	return \@samples;
}


