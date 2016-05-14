#!/bin/env perl
use strict;
use warnings;
use autodie;
use 5.010;

use Bio::SeqIO;

my $filename  = shift // usage();
my $num_files = shift // usage();

usage() if substr($filename,0,2) eq '-h';
usage() if substr($num_files,0,2) eq '-h';

# Read in all of the sequence data
my $fasta_obj = Bio::SeqIO->new( -file => $filename, -format => 'FASTA');

my $fh_next = _fh_iterator($num_files);

while (my $seq_obj = $fasta_obj->next_seq)
{
    my $fh = $fh_next->(); 
    say {$fh} '>' . $seq_obj->id;
    say {$fh} $seq_obj->seq;
}

sub _fh_iterator
{
    my $num_files = shift;

    # create file handles
    my %fh_for;
    for my $num ( 1 .. $num_files )
    {
        open(my $fh, '>', $filename . '_' . $num_files . '_' . $num); 
        $fh_for{$num} = $fh;
    }

    my $current = 0; 

    return sub {
        $current++;
        if ($current > $num_files)
        {
            $current = 1;
        }

        return $fh_for{$current};
    };

}

sub usage 
{
    die "USAGE:\n\t$0 filename num_of_files_desired\n";
}
