#!/bin/env perl6

use Test;

my $control = write-file( control );
my $sampleA = write-file( sample );
my $sampleB = write-file( sampleB );
my $output  = temp-filename; 

shell("./subtract_control_nick_sites --control=$control $sampleA $sampleB > $output");

my $result = slurp $output;

is remove-header($result), remove-header(expected), "Correctly normalized read counts";

unlink $control, $output;

done-testing;

sub control 
{
    return q:to/END/;
        position	forward	reverse
        1	10	22
        2	20	44
        END
}

# double control, but should be normalized to be the same
sub sample
{
    return q:to/END/;
        position	forward	reverse
        1	20	44
        2	40	88
        END
}

# half control, but should be normalized to be the same
sub sampleB
{
    return q:to/END/;
        position	forward	reverse
        1	 6	10
        2	10	22
        END
}

sub expected
{
    return q:to/END/;
        position	forward	reverse
        1	0	0	20833.33	-20833.33
        2	0	0	0	0
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

    if "/tmp".IO.d && "/tmp".IO.w && "/tmp".IO.r
    {
        $temp-filename = "/tmp/$temp-filename";
    }

    return $temp-filename;
}

sub remove-header ($string)
{
    my $out;
    for $string.lines -> $line
    {
        once { next; }
        $out~="$line\n";
    }
    return $out;
}
