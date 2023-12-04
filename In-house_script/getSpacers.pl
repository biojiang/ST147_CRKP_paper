#!/usr/bin/perl -w
use strict;
use warnings;

my @files = glob "./crispr/*";
my @ie = ();
my @iv = ();
for my $f(@files)
{
	$f =~ /\.\/crispr\/(.+)/;
	my $name = $1;
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
				if($arr[13] eq 'I-E')
				{
					push @ie,"$f/spacers/".$arr[1].".fa";
				}
				if($arr[13] eq 'IV-A3')
                                {
                                        push @iv,"$f/spacers/".$arr[1].".fa";
                                }

			}
		}
	}
	else
	{
		#$res{$name} = 1;
		next;
	}

}
my $cmd1 = join(" ",@ie);
system("cat $cmd1 > ST147.IE.spacer.fasta");
$cmd1 = join(" ",@iv);
system("cat $cmd1 > ST147.IV-A3.spacer.fasta");


