#!/bin/env perl6

use Test;

%*ENV<HOME> = '/home/bottomsc/test-home';

my $home = %*ENV<HOME>;

mkdir "$home/reports";

my $yesterday's-file = "$home/reports/" ~ Date.today.earlier( day => 1 ).Str ~ ".txt";
my $today's-file     = "$home/reports/" ~ Date.today.Str                     ~ ".txt";

spurt $yesterday's-file, yesterday's-report;

shell "daily";

my $today's-report = slurp $today's-file;

is $today's-report, expected, "Created today's report based on yesterday's";

unlink $yesterday's-file;
unlink $today's-file;

done-testing;

sub yesterday's-report 
{
    return q:to/END/;
        1. Testing

        Next ID: 3;
        END
}

sub expected
{
    return q:to/END/;
        1. Testing

        Next ID is 2
        END
}
