#!/usr/bin/perl

use strict;
use warnings;

use 5.010;
use autodie;

sub indentByLeven()
{
    my $fin = shift;

    open my $fh, '<', $fin;
    my @data = <$fh>;
    close $fh;


    my @newdata;
    foreach my $line (@data) {
        my @fields = split ',', $line;
        my $level = $fields[3];
        #my $level = substr($line, 38, 2);
        #$level =~ s/ // ;
        $fields[4] =~ s/^\s+//;
        if ( $level =~/\d/ and $level > 0) {
            splice @fields, 4, 0, "," x $level;
            #$fields[3] = "," x $level;
            #$line =~ s/(.{40}),\s+(.*)$/$1$commas,$2/;
        }
        $line = join ',', @fields;
        push @newdata, $line;
    }
    &highLightMissingTime(\@newdata);
    $fin = $fin . ".new.csv";
    open $fh, '>', $fin;
    print $fh @newdata;
}

sub highLightMissingTime()
{
    my $dataref = shift;
    my @data = @{ $dataref };
}

sub main
{
    my @csvs = glob("*.nest.csv");

    foreach my $fin (@csvs) {
        &indentByLeven($fin);
    }
}

&main;
