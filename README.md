# in-house-scripts

Description

Metagenomic reads were quality filtered and trimmed using the three Perl scripts 

Usage

perl 1_reads_with_duplication_filter.pl -fq1 input_1.fq -fq2 input_2.fq -out output

perl 2_reads_with_excess_of_N_filter.pl output_1.fq output_2.fq output_1_1.fq output_2_2.fq 5

perl 3_reads_with_trimm_low_quality.pl output_1_1.fq output_2_2.fq output_1_1_1.fq output_2_2_2.fq 20
