#!/bin/env perl6

use Test;

my $in-filename = write-file( input );

my $out-filename = temp-filename;

shell("./grab_fasta_record_for --start='2' $in-filename > $out-filename");

my $result = slurp($out-filename);

is $result, expected, 'Correctly extracted FASTA record';

unlink $in-filename, $out-filename;

done-testing;

sub input 
{
    return q:to/END/;
        >1
        AAAAA
        >2
        CCCCC
        >3
        GGGGG
        END
}

sub expected
{
    return q:to/END/;
        >2
        CCCCC
        END
}

sub write-file ( $string )
{
    my $filename = temp-filename;
    spurt($filename, $string);
    return $filename;
}

sub temp-filename
{
    # set subsecond time as starting random value and increment it with
    #  subsequent calls 
    state $time = now.Num;
    $time += 1;

    my $temp-filename = "temp.$time";

    #    if "/tmp".IO.d && "/tmp".IO.w && "/tmp".IO.r
    #    {
    #        $temp-filename = "/tmp/$temp-filename";
    #    }

    return $temp-filename;
}
