#!/usr/bin/perl

#use strict;
#use warnings;
use feature ":5.10";
use File::Copy;

# prompt user 
sleep(1);print "\nType name of your clustal alignment file without extension (e.g. 1rex_align)\n\n";
my $clustalID = <STDIN>;
chop($clustalID);

print "\nENTER THE NUMBER OF VARIANTS IN YOUR .aln FILE (i.e. number of rows minus one)\n\n";
$varnum = <STDIN>;
chop($varnum);
sleep(1);
$Vnum = $varnum;

open(INFILE, $clustalID.".aln") or die "Cannot open input file";
open (OUTFILE, ">".$clustalID.".fasta") || die " could not open output file\n";

# collect array of headers
open(IN, "<"."$clustalID".".aln");
@IN = <IN>;
@headers = ();
for (my $i = 0; $i < $varnum+3; $i++){
	 if ($i<=1){next;}
	 my $INrow = $IN[$i];
     my @INrow = split (/\s+/, $INrow);
	 my $header = $INrow[0];
     push(@headers, $header);
	 }
     print @headers;
	print"\n";
close IN;

# process array
for (my $j = 0; $j < scalar @headers; $j++){
$sequence = "";
open(IN, "<"."$clustalID".".aln");
@IN = <IN>;
for (my $jj = 0; $jj < scalar @IN; $jj++) {
    $INrow = @IN[$jj];
    @INrow = split(/\s+/, $INrow);
    $test = @INrow[0];
    $seq = @INrow[1];
    $header = @headers[$j];
    print "looking for $header\n";
    if ($header eq $test){$sequence = $sequence.$seq; print " building "."$sequence\n";}
}
if($header ne '' && $sequence ne ''){
print OUTFILE ">$header\n";
print OUTFILE "$sequence\n";
}
close IN;    
}
close OUTFILE;
close INFILE;

exit;
