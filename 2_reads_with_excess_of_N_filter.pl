#!perl -w
use warnings;
use strict;

#N_num is 10
open( FASTQ1,  "<$ARGV[0]" ) or die "can't open file $ARGV[0]";
open( FASTQ2,  "<$ARGV[1]" ) or die "can't open file $ARGV[1]";
open( OUTPUT1, ">$ARGV[2]" ) or die "can't create file $ARGV[2]";
open( OUTPUT2, ">$ARGV[3]" ) or die "can't create file $ARGV[3]";
my $N_num = $ARGV[4];

my $counter    = 0;
my $total      = 0;
my $reads1     = "";
my $reads2     = "";
my $out_line_1 = "";
my $out_line_2 = "";
my $clean      = 0;
while (my $line = <FASTQ1>) {
	if ( $line ne "" ) {
		$reads1 .= $line;
		$line = <FASTQ1>;
		$reads1 .= $line;
		$line =~ s/^\s+|\s+$//ig;
		my @fields1 = split //, $line, -1;
		$line = <FASTQ1>;
		$reads1 .= $line;
		$line = <FASTQ1>;
		$reads1 .= $line;
		my $oLine = <FASTQ2>;
		$reads2 .= $oLine;
		$oLine = <FASTQ2>;
		$reads2 .= $oLine;
		$oLine =~ s/^\s+|\s+$//ig;
		my @fields2 = split //, $oLine, -1;
		$oLine = <FASTQ2>;
		$reads2 .= $oLine;
		$oLine = <FASTQ2>;
		$reads2 .= $oLine;

		for ( my $i = 0 ; $i < scalar(@fields1) ; $i++ ) {
			if ( $fields1[$i] eq "N" || $fields1[$i] eq "n" ) {
				$counter++;
			}
		}
		for ( my $i = 0 ; $i < scalar(@fields2) ; $i++ ) {
			if ( $fields2[$i] eq "N" || $fields2[$i] eq "n" ) {
				$counter++;
			}
		}
		if ( $counter <= $N_num ) {
			$out_line_1 .= $reads1;
			$out_line_2 .= $reads2;
			$clean++;
		}
		if ( $clean % 100000 == 0 ) {    ### 减少输出次数，降低 io
			print OUTPUT1 $out_line_1;
			print OUTPUT2 $out_line_2;
			$out_line_1 = "";
			$out_line_2 = "";
		}
		$counter = 0;
		$total++;
		$reads1 = "";
		$reads2 = "";
	}
	else{
		last;
	}
}
if ( $clean % 100000 != 0 ) {
	print OUTPUT1 $out_line_1;
	print OUTPUT2 $out_line_2;
}
print "total number of reads is $total.\n"
  . "number of reads with number of N less than $N_num"
  . " is $clean.\n";
close OUTPUT1;
close OUTPUT2;
close FASTQ1;
close FASTQ2;
