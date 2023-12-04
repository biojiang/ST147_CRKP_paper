#!/usr/bin/perl -w
use strict;
use warnings;

my $genome_dir = $ARGV[0];
my $out_dir = $ARGV[1];
my $type = $ARGV[2];

my @files = glob "./crispr/*";
for my $f(@files)
{
        $f =~ /\.\/crispr\/(.+)/;
        my $name = $1;
	my %pos = ();
	if(-e "$f/crisprs.gff")
	{
		open IN,"<$f/crisprs.gff";
		<IN>;
		while(my $line = <IN>)
		{
			chomp $line;
			my @arr = split/\t/,$line;
			if($arr[2] eq 'binding_site')
			{
				$arr[-1] =~ /ID=(.+?)\;/;#ID=56682__15_1_SPACER1;
				my $id = $1;
				$id =~ s/_SPACER/:/;
			}
		}
	}
	my $IE_self_site = 0;
	open OUT,">$out_dir/$name.blast";
        if(-e "$f/crisprs_all.tab")
        {
                open IN,"<$f/crisprs_all.tab";
                <IN>;
                while(my $line = <IN>)
                {
                        chomp $line;
                        my @arr = split/\t/,$line;
                        if($arr[11] eq 'True')
                        {
                                if($arr[13] eq $type)
                                {
					my $spacer_file = "$f/spacers/".$arr[1].".fa";
					my $blast = `blastn -task blastn-short -query $spacer_file -db $genome_dir/$name.fasta -evalue 1e-5 -num_threads 40 -outfmt 6 -qcov_hsp_perc 100`;
					my @res = split/\n/,$blast;
					for my $r(@res)
					{
						my @ele = split/\t/,$r;
						if(not exists $pos{$ele[0]}{$ele[8]} or not exists $pos{$ele[0]}{$ele[9]})
						{
							$IE_self_site++;
							print OUT $r,"\n";
						}
					}
                                }

                        }
                }
        }
	else
        {
                next;
        }
	my $flag = 0;
	if($IE_self_site > 0)
	{
		$flag = 1;
	}

}





