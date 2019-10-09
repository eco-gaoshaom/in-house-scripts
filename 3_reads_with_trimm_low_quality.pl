#!perl -w
use warnings;
use strict;

#trim_number 20
open( FASTQ1,  "<$ARGV[0]" ) or die "can't open file $ARGV[0]";
open( FASTQ2,  "<$ARGV[1]" ) or die "can't open file $ARGV[1]";
open( OUTPUT1, ">$ARGV[2]" ) or die "can't create file $ARGV[2]";
open( OUTPUT2, ">$ARGV[3]" ) or die "can't create file $ARGV[3]";
my $trim_Quality = $ARGV[4];

my $counter     = 0;
my $total       = 0;
my @reads1      = ();
my @reads2      = ();
my $out_line_1  = "";
my $out_line_2  = "";
my $clean       = 0;
my $trim_head_1 = 0;
my $trim_head_2 = 0;
my $trim_end_1  = 0;
my $trim_end_2  = 0;
my $tempLine    = "";
while (1) {
	my $line = <FASTQ1>;
	if ( $line ne "" ) {
		push @reads1, $line;
		$line = <FASTQ1>;
		push @reads1, $line;
		$line = <FASTQ1>;
		push @reads1, $line;
		$line = <FASTQ1>;
		push @reads1, $line;
		$line =~ s/^\s+|\s+$//ig;
		my @fields1 = split //, $line, -1;
		my $oLine = <FASTQ2>;
		push @reads2, $oLine;
		$oLine = <FASTQ2>;
		push @reads2, $oLine;
		$oLine = <FASTQ2>;
		push @reads2, $oLine;
		$oLine = <FASTQ2>;
		push @reads2, $oLine;
		$oLine =~ s/^\s+|\s+$//ig;
		my @fields2 = split //, $oLine, -1;

		for ( my $i = 0 ; $i < scalar(@fields1) ; $i++ ) {
			if ( ord( $fields1[$i] ) - 33 < $trim_Quality ) {
				$trim_head_1++;
				$counter++;
			}
			else {
				last;
			}
		}
		for ( my $i = scalar(@fields1) - 1 ; $i >= 0 ; $i-- ) {
			if ( ord( $fields1[$i] ) - 33 < $trim_Quality ) {
				$trim_end_1++;
				$counter++;
			}
			else {
				last;
			}
		}

		for ( my $i = 0 ; $i < scalar(@fields2) ; $i++ ) {
			if ( ord( $fields2[$i] ) - 33 < $trim_Quality ) {
				$counter++;
				$trim_head_2++;
			}
			else {
				last;
			}
		}
		for ( my $i = scalar(@fields2) - 1 ; $i >= 0 ; $i-- ) {
			if ( ord( $fields2[$i] ) - 33 < $trim_Quality ) {
				$counter++;
				$trim_end_2++;
			}
			else {
				last;
			}
		}
		if ( scalar(@fields2) - $trim_end_1 - $trim_end_2 > 0 ) {
			$tempLine =
			  substr( $reads1[1], $trim_head_1,
				scalar(@fields1) - $trim_head_1 - $trim_end_1 );
			$reads1[1] = $tempLine . "\n";
			$tempLine =
			  substr( $reads1[3], $trim_head_1,
				scalar(@fields1) - $trim_head_1 - $trim_end_1 );
			$reads1[3] = $tempLine . "\n";
			$tempLine =
			  substr( $reads2[1], $trim_head_2,
				scalar(@fields2) - $trim_head_2 - $trim_end_2 );
			$reads2[1] = $tempLine . "\n";
			$tempLine =
			  substr( $reads2[3], $trim_head_2,
				scalar(@fields2) - $trim_head_2 - $trim_end_2 );
			$reads2[3] = $tempLine . "\n";
			$out_line_1 .= join( "", @reads1 );
			$out_line_2 .= join( "", @reads2 );
			$clean++;
		}

		if ( $clean % 100000 == 0 ) {    ### 减少输出次数，降低 io
			print OUTPUT1 $out_line_1;
			print OUTPUT2 $out_line_2;
			$out_line_1 = "";
			$out_line_2 = "";
		}
		$counter     = 0;
		$trim_end_1  = 0;
		$trim_end_2  = 0;
		$trim_head_1 = 0;
		$trim_head_2 = 0;
		$total++;
		@reads1 = ();
		@reads2 = ();
	}
	else {
		last;
	}
}
if ( $clean % 100000 != 0 ) {
	print OUTPUT1 $out_line_1;
	print OUTPUT2 $out_line_2;
}
print "total number of reads is $total.\n"
  . "number of reads with number of N less than $trim_Quality"
  . " is $clean.\n";
close OUTPUT1;
close OUTPUT2;
close FASTQ1;
close FASTQ2;
