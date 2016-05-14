#!/bin/env perl
use strict;
use warnings;
use autodie;
use 5.012;

use Bio::SeqIO;

my $filename  = shift // usage();
my $num_files = shift // usage();

usage() if substr($filename,0,2)  eq '-h';
usage() if substr($num_files,0,2) eq '-h';


# Read in all of the sequence data
my $bio_obj = Bio::SeqIO->new( -file => $filename, -format => 'FASTA');

my @seq_objs;

while (my $seq_obj = $bio_obj->next_seq)
{
    push @seq_objs, $seq_obj;
}

my @fasta_sets = fair_lists( \@seq_objs, $num_files);  

for my $index ( 0 .. $#fasta_sets)
{
    my $num = $index + 1;
    open(my $fh, '>', $filename . '_' . $num_files . '_' . $num);
    print_fasta( $fh, $fasta_sets[ $index ] ); 
}

sub print_fasta
{
    my $fh         = shift;
    my $fasta_aref = shift;
    
    for my $seq_obj (@{ $fasta_aref} )
    {
        say {$fh} '>' . $seq_obj->id;
        say {$fh} $seq_obj->seq;
    }
    close $fh;
}

sub fair_lists 
{
    my @array        = @{ shift() };
    my $num_lists    = shift;
    my $num_elements = scalar @array;

    if ($num_lists > $num_elements) {
        my @one_element_lists = map { [ $_ ] } @array; 
        return @one_element_lists;
    }

    my $num_large    = $num_elements % $num_lists; # remainder
    my $num_small    = $num_lists - $num_large;

    my $small_size = int($num_elements/$num_lists);
    my $large_size = $small_size + 1; # same as ceiling($num_element/$num_lists);

    my $first_small = ($num_large * $large_size);
    my $last_large  = $first_small - 1;
     
    my @first_sublist  = @array[ 0 .. $last_large];
    my @second_sublist = @array[ $first_small .. $num_elements - 1 ];

    my @large_lists = rotor( \@first_sublist, $large_size);
    my @small_lists = rotor( \@second_sublist,  $small_size);
    my @all_lists   = (@large_lists, @small_lists);
    return @all_lists;
}

sub rotor
{
    my @array         = @{ shift() };
    my $num_per_array = shift;
    my $elements      = scalar @array;
    my $num_of_arrays = $elements / $num_per_array;
  
    my $start_index = 0;
    my $last_index = $num_per_array - 1; 
    my @out_arrays;
    for my $array_num ( 1 .. $num_of_arrays)
    {
        my @temp_array = @array[ $start_index .. $last_index ];      
        push @out_arrays, \@temp_array;
        $start_index += $num_per_array;
        $last_index  += $num_per_array;
    } 
    return @out_arrays; 
}

sub usage 
{
    die "USAGE:\n\t$0 filename num_of_files_desired\n";
}
