#!/usr/bin/perl

use strict;
use warnings;

use 5.010.001;
use autodie;

&main;

sub IndentByLevelNum ()
{
    my $dataref = shift;
    foreach my $line (@$dataref) {
        $line = &ReplaceSpaceWithComma($line);
    }
}

sub HighLightMissingTime ()
{
    my $dataref = shift;

    my $limit = 1;    # time missing limit in ms.
    my $descrip = "A period of missing time in profiler\n";
    my %last    = ( start => 0, end => 0, level => 0 );
    my %current;
    my @newdata;

    for my $line (@$dataref) {
        my @fields = split ',', $line;
        next unless $#fields >= 3;

        $current{'level'} = $fields[3];
        $current{'start'} = $fields[0];
        $current{'end'}   = $fields[1];

        if (    $current{'level'} =~ /\d/
            and $current{'level'} <= $last{'level'}
            and $current{'start'} - $last{'end'} >= $limit )
        {
            my $deltaTime = sprintf "%11.2f", $current{'start'} - $last{'end'};
            my $missing   = join ",", $last{'end'}, $current{'start'},
              $deltaTime, $last{'level'}, $descrip;
            push @newdata, $missing;
        } elsif ( $current{'level'} =~ /\d/
            and $current{'level'} > $last{'level'}
            and $current{'start'} - $last{'start'} >= $limit )
        {
            my $deltaTime = sprintf "%11.2f",
              $current{'start'} - $last{'start'};
            my $missing = join ",", $last{'start'}, $current{'start'},
              $deltaTime, $current{'level'}, $descrip;
            push @newdata, $missing;
        }
        push @newdata, $line;
        %last = %current;
    }
    return \@newdata;
}

sub main
{
    # TODO consider other ways to use, e.g. given directories as arguments.
    my @csvs = glob("*.nest.csv");

    foreach my $fin (@csvs) {
        my $csv = &GetCsvFileContent($fin);
        &IndentByLevelNum($csv);
        $csv = &HighLightMissingTime($csv);
        &WriteToFile( $fin, $csv );
    }
}

=pod
  START(ms),   STOP(ms),ELAPSED(ms), LEVEL, DESCRIPTIONS,
       0.00,     170.72,     170.72,   0,   Test: EFUSE0_IRC [Execute Flow Node],
       0.26,       0.27,       0.01,   1,    PinTypeAtTest,
      11.42,      11.52,       0.10,   2,     Wait for Queued Setup Delay,
=cut

sub ReplaceSpaceWithComma ()
{
    my $line = shift;

    my @fields = split ',', $line;
    my $level  = $fields[3];

    if ( $level =~ /\d/ and $level >= 0 ) {
        $fields[4] =~ s/^\s+//;
        $fields[4] = ( "," x $level ) . $fields[4];
    }
    $line = join ',', @fields;
}

sub GetCsvFileContent ()
{
    my $fin = shift;

    open my $fh, '<', $fin;
    my @data = <$fh>;
    close $fh;
    return \@data;
}

sub WriteToFile ()
{
    my $fn      = shift;
    my $dataref = shift;

    $fn .= ".new.csv";
    open my $fh, '>', $fn;
    print $fh @$dataref;
}
