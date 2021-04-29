#!/usr/bin/perl

#use strict;
#use warnings;
use feature ":5.10";
use File::Copy;
open(INFILE, "myASR.txt") or die "Cannot open input file";
# prompt user 
sleep(1);print "\nSelect new name of your alignment file without extension (e.g. 1rex_asr)\n\n";
my $clustalID = <STDIN>;
chop($clustalID);
open (OUTFILE, ">".$clustalID.".aln") || die " could not open output file\n";
print OUTFILE "CLUSTAL W ALN saved from UCSF Chimera/MultAlignViewer\n\n";
@IN = <INFILE>;
for (my $j = 0; $j < scalar @IN; $j++) {
    $INrow = @IN[$j];
    @INrow = split(/:/, $INrow);
    $head = @INrow[0];
    @head = split(/\./, $head, 2);
    $head = @head[1];
    $seq = @INrow[1];
    if($seq =~ m/[A-Z]\s/) {print OUTFILE "$head\t"."$seq";}
}
close OUTFILE;
close INFILE;
print "\n modify text file exactly to match EXAMPLE of clustal format\n\n";
system "gedit ".$clustalID.".aln 1rex_asr_example.aln";
exit;
