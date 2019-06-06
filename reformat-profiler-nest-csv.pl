#!/usr/bin/perl

use strict;
use warnings;

use 5.014;
use autodie;

foreach my $fin (@ARGV) {
    open my $fh, '<', $fin;
    my @data = <$fh>;
    close $fh;


    my @newdata;
    foreach my $line (@data) {
        my $level = substr($line, 38, 2);
        $level =~ s/ // ;
        my $commas = "," x $level;
        if ( $level > 0) {
            $line =~ s/(.{40}),\s+(.*)$/$1$commas,$2/;
        }
        push @newdata, $line;

        #my @cols = split($line,",");
        #print "@cols";

        #my $level = $cols[3];
        #my $commas = "," x $level;
        #$cols[5] = $cols[4];
        #$cols[4] = $commas;

        #$line = join ",", @cols;
        #print $line;
    }
    $fin = $fin . ".new.csv";
    open $fh, '>', $fin;
    print $fh @newdata;
}
