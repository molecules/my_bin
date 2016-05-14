#!/bin/env perl
use strict;
use warnings;
use autodie;
use 5.012;

use Bio::SeqIO;
use Math::Utils qw( floor );

my $filename     = shift;
my $num_files = shift;

# create file handles
my %fh_for;
for my $num ( 1 .. $num_files )
{
    open(my $fh, '>', $filename . '_' . $num_files . '_' . $num); 
    $fh_for{$num} = $fh;
}

# Read in all of the sequence data
my $bio_obj = Bio::SeqIO->new( -file => $filename, -format => 'FASTA');

my @seq_objs;

while (my $seq_obj = $bio_obj->next_seq)
{
    push @seq_objs, $seq_obj;
}

# Determine the best way to split up the data
my $num_seqs = scalar @seq_objs;

my $min_seq_per_file = floor($num_seqs / $num_files);
my $max_seq_per_file = $min_seq_per_file + 1;

my $extra_counter = my $num_files_with_an_extra = $num_seqs - ($min_seq_per_file * $num_files);
my $min_counter   = my $num_files_with_min = $num_files - $num_files_with_an_extra;

my $index_of_fh = 1;

my $current_read_number = 0;

for my $seq_obj (@seq_objs)
{
    say '>' . $seq_obj->id;
    say $seq_obj->seq;
}

