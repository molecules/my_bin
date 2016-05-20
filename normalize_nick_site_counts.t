#!/bin/env perl6

use Test;

my $input-filename  = temp-filename; 

spurt($input-filename, input);

my $output-filename = temp-filename; 

shell("./normalize_nick_site_counts $input-filename > $output-filename");

my $result = slurp $output-filename;

is $result, expected, "Correctly normalized read counts";

unlink $input-filename, $output-filename;

sub input 
{
    return q:to/END/;
        position	forward	reverse
        1	10	20
        2	25	45
        END
}

sub expected
{
    return q:to/END/;
        position	forward	reverse
        1	100000	200000
        2	250000	450000
        END
}

sub temp-filename
{
    # set subsecond time as starting random value and increment it with
    #  subsequent calls 
    state $time = now.Num;
    $time += 1;

    my $temp-filename = "temp.$time";

    if "/tmp".IO.d && "/tmp".IO.w && "/tmp".IO.r
    {
        $temp-filename = "/tmp/$temp-filename";
    }

    return $temp-filename;
}
