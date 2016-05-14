#!/bin/env perl
use 5.010;    # Require at least Perl version 5.10
use strict;   # Must declare all variables before using them
use warnings; # Emit helpful warnings
use autodie;  # Fatal exceptions for common unrecoverable errors (e.g. w/open)

# Testing-related modules
use Test::More;                  # provide testing functions (e.g. is, like)
use Test::LongString;            # Compare strings byte by byte
use Data::Section -setup;        # Set up labeled DATA sections
use File::Temp  qw( tempfile );  #
use File::Slurp qw( slurp    );  # Read a file into a string
use File::Path qw( make_path remove_tree);
use Carp        qw( croak    );  # Push blame for errors back to line calling function

test(3);

sub test
{
    my $num_files = shift;
    my $infile  = filename_for('input');
    system("fasta_split.pl $infile $num_files");

    for my $num (1 .. $num_files)
    {
        my $suffix            = '_' . $num_files . '_' . $num;
        my $result_filename   = $infile . $suffix;
        my $result            = slurp $result_filename;
        my $expected          = string_from('expected' . $suffix);
        is( $result, $expected, 'successfully created and manipulated temp files' );
        unlink $result_filename;
    }

    unlink $infile;
}

done_testing();

sub sref_from {
    my $section = shift;

    #Scalar reference to the section text
    return __PACKAGE__->section_data($section);
}

sub string_from {
    my $section = shift;

    #Get the scalar reference
    my $sref = sref_from($section);

    #Return a string containing the entire section
    return ${$sref};
}

sub fh_from {
    my $section = shift;
    my $sref    = sref_from($section);

    #Create filehandle to the referenced scalar
    open( my $fh, '<', $sref );
    return $fh;
}

sub assign_filename_for {
    my $filename = shift;
    my $section  = shift;

    # Don't overwrite existing file
    croak "'$filename' already exists." if -e $filename;

    my $string   = string_from($section);
    open(my $fh, '>', $filename);
    print {$fh} $string;
    close $fh;
    return;
}

sub filename_for {
    my $section           = shift;
    my ( $fh, $filename ) = tempfile();
    my $string            = string_from($section);
    print {$fh} $string;
    close $fh;
    return $filename;
}

sub temp_filename {
    my ($fh, $filename) = tempfile();
    close $fh;
    return $filename;
}

sub delete_temp_file {
    my $filename  = shift;
    my $delete_ok = unlink $filename;
    ok($delete_ok, "deleted temp file '$filename'");
    return;
}

sub remove_temp_dir {
    my $dirname = shift;
    my $delete_ok = remove_tree($dirname);
    ok($delete_ok, "Deleted temp dir '$dirname'");
}

#------------------------------------------------------------------------
# IMPORTANT!
#
# Each line from each section automatically ends with a newline character
#------------------------------------------------------------------------

__DATA__



__[ input ]__
>A
AAAA
CCCC
GG
TTTT
>B
AAAAAAAA
C
GT
>C
AAAAAAAAAAAAAAAAAA
>D
CCCCCCCCCCCCCCCCCCCCCC
>E
GGGGGGGGGGGGGG
>F
TTTTTTTTTTTTTTTT
>H
AAAAAAAAAAAAAAAA
__[ expected ]__
>A
AAAACCCCGGTTTT
>B
AAAAAAAACGT
>C
AAAAAAAAAAAAAAAAAA
>D
CCCCCCCCCCCCCCCCCCCCCC
>E
GGGGGGGGGGGGGG
>F
TTTTTTTTTTTTTTTT
>H
AAAAAAAAAAAAAAAA
__[ expected_3_1 ]__
>A
AAAACCCCGGTTTT
>B
AAAAAAAACGT
__[ expected_3_2 ]__
>C
AAAAAAAAAAAAAAAAAA
>D
CCCCCCCCCCCCCCCCCCCCCC
__[ expected_3_3 ]__
>F
TTTTTTTTTTTTTTTT
>H
AAAAAAAAAAAAAAAA
