#!/usr/bin/perl

#use strict;
#use warnings;
use feature ":5.10";
use File::Copy;
use Statistics::Descriptive();

# specify the path to working directory for Chimera here
open(IN, "<"."paths.ctl") or die "could not find paths.txt file\n";
my @IN = <IN>;
for (my $i = 0; $i < scalar @IN; $i++){
	 my $INrow = $IN[$i];
	 my @INrow = split (/\s+/, $INrow);
	 my $header = @INrow[0];
	 my $path = @INrow[1];
	 if ($header eq "chimera_path"){$chimera_path = $path;}
	 if ($header eq "chimerax_path"){$chimerax_path = $path;}
}
close IN;
# prompt user 
sleep(1);print "\nType PDB ID for reference protein (e.g. 1rex)\n\n";
my $pdbID = <STDIN>;
chop($pdbID);
sleep(1);print "\nType length of protein (i.e. number of sites in PDB file)\n\n";
my $lengthID = <STDIN>;
chop($lengthID);
sleep(1);print "\nType name of your alignment file without extension (e.g. 1rex_asr)\n\n";
my $clustalID = <STDIN>;
chop($clustalID);
sleep(1);print "\nENTER THE NUMBER OF VARIANT + ANCESTRAL SEQUENCES IN YOUR .aln FILE (i.e. number of rows minus one)\n\n";
system "gedit $clustalID.aln";
$varnum = <STDIN>;
chop($varnum);

$bootsYN = 'n';
sleep(1);print "\n Do you want to bootstrap sample the mutations of each branch? (for weights and t-tests; enter y or n)\n\n";
my $bootsYN = <STDIN>;
chop($bootsYN);
if ($bootsYN eq ''){$bootsYN = 'n';}
if ($bootsYN eq 'Y'){$bootsYN = 'y';}
if ($bootsYN eq 'N'){$bootsYN = 'n';}
if ($bootsYN eq 'yes'){$bootsYN = 'y';}
if ($bootsYN eq 'no'){$bootsYN = 'n';}
if ($bootsYN eq 'YES'){$bootsYN = 'y';}
if ($bootsYN eq 'NO'){$bootsYN = 'n';}
if($bootsYN eq 'n'){goto HERE;}
sleep(1);print "\nEnter number of bootstraps for sampling mutations on each branch\n\n";
my $boots = <STDIN>;
chop($boots);
HERE:

#$pdbID = "1rex";
#$lengthID = 130;
#$clustalID = "1rex_asr";
#$varnum = 15;

mkdir('energy_trees');
copy("myTree.nwk", "energy_trees/myTree.nwk") || die "could not find myTree.nwk file\n";
copy("myChanges.csv", "energy_trees/myChanges.csv") || die "could not find myChanges.csv file\n";

print "collecting files and matching to tree\n";
# create array of data file names from PDB list
@PDBlist = ();
open(IN, "<"."./pdb_mutants/mutants.txt") or die "could not find PDB list file\n";
my @IN = <IN>;
for (my $i = 0; $i < scalar @IN; $i++){
	 my $INrow = $IN[$i];
	 my @INrow = split (/\s+/, $INrow);
	 my $name = @INrow[0];
      push(@PDBlist, "$name");
}
close IN;
@PDB2list = ();
open(IN, "<"."./pdb_mutants/mutants.txt") or die "could not find PDB list file\n";
my @IN = <IN>;
for (my $i = 0; $i < scalar @IN; $i++){
	 my $INrow = $IN[$i];
	 my @INrow = split (/\s+/, $INrow);
	 my $name = @INrow[0];
      push(@PDB2list, "final_$name");
}
close IN;
# create matching array of branch names (sequence headers) from MSA 
@ALNlist = ();
open(IN, "<"."$clustalID.aln") or die "could not find alignment file\n";
my @IN = <IN>;
for (my $i = 0; $i < $varnum +2; $i++){
      if($i == 0){next;}
	 my $INrow = $IN[$i];
	 my @INrow = split (/\s+/, $INrow);
	 my $name = @INrow[0];
      push(@ALNlist, $name);
}
close IN;
print "PDB list\n";
print @PDBlist;
print "\n\n";
print "PDB2 list\n";
print @PDB2list;
print "\n\n";
print "ALN list\n";
print @ALNlist;
print "\n\n";
if(scalar @PDBlist != scalar @ALNlist){sleep(3); print "WARNING: alignment does not match number of PDB files\n\n"; exit;}
elsif(scalar @PDBlist == scalar @ALNlist){sleep(3); print "PDB file list matches alignment...continuing\n\n"; sleep(2);}

#prompt user for ASR sequences to match bottom of each branch
sleep(1);print "\nFOR EACH BRANCH IN YOUR TREE ENTER THE CORRESPONDING CLOSEST ANCESTOR IN ADJACENT COLUMN (with tab in between), THEN SAVE AND CLOSE (SEE EXAMPLE)\n\n";
open (ASR, ">"."AlnAsr_list.txt");
print ASR "branch_tip\t"."branch_root\n";
for (my $i = 1; $i < scalar @ALNlist; $i++){
      my $name = @ALNlist[$i];
      print ASR "$name\n";
      }
close ASR;
system "gedit AlnAsr_list.txt AlnAsr_listEXAMPLE.txt\n";
@ALNlist = ();
@ASRlist = ();
open (ASR, "<"."AlnAsr_list.txt");
@ASR = <ASR>;
for (my $i = 0; $i < scalar @ASR; $i++){
      if ($i == 0){next;}
      my $INrow = $ASR[$i];
	 my @INrow = split (/\s+/, $INrow);
      $match1 = @INrow[0];
      if($match1 ne ""){push(@ALNlist, $match1);}
      $match2 = @INrow[1];
      if($match2 ne ""){push(@ASRlist, $match2);}
}
print "ALN and ASR list\n";
print scalar @ALNlist;
print "\n";
print scalar @ASRlist;
print "\n\n";
if(scalar @ASRlist != scalar @ALNlist){sleep(3); print "WARNING: length of ALNlist does not match length of ASRlist\n\n"; exit;}
elsif(scalar @ASRlist == scalar @ALNlist){sleep(3); print "ASR file list matches alignment...continuing\n\n"; sleep(2);}
sleep(1);
# copy maestro history files and relabel to match branch
for (my $i = 0; $i < scalar @ALNlist; $i++){
   #sleep(1);
   $myPDB = @PDB2list[$i];
   $myALN = @ALNlist[$i];
   print "collecting maestro data for $myALN \n";
   copy("maestro_history/$myPDB"."_history.maestro", "energy_trees/$myALN"."_history.maestro"); # || die "could not find $pdbID"."_history.maestro file\n";
}
# copy MD output and flux files and relabel to match branch
for (my $i = 0; $i < scalar @ALNlist; $i++){
   #sleep(1);
   $myPDB = @PDBlist[$i];
   $myALN = @ALNlist[$i];
   print "collecting MD simulation data for $myALN \n";
   copy("MDoutput/prod_$myPDB"."REDUCED_0.out", "energy_trees/$myALN"."_MD.out"); # || die "could not find $pdbID"."_history.maestro file\n";
}
for (my $i = 0; $i < scalar @ALNlist; $i++){
   #sleep(1);
   $myPDB = @PDBlist[$i];
   $myALN = @ALNlist[$i];
   print "collecting MD fluctuation data for $myALN \n";
   copy("fluct_$myPDB"."_0.txt", "energy_trees/$myALN"."_fluct.txt"); # || die "could not find $pdbID"."_history.maestro file\n";
}

# collect mutational changes on each branch of guide tree
open (OUTFILE, ">"."energy_trees/energy_changes.txt") || die " could not open output file\n";
print OUTFILE "branch\t"."site\t"."change\t"."ddG\t"."dRMSF\n";
open (OUTFILE2, ">"."energy_trees/branch_weights_ddG.txt") || die " could not open output file\n";
print OUTFILE2 "branch\t"."avgDDG_observed\t"."avgDDG_potential\t"."ddG_omega\t"."d_value\t"."effect_size(S,M*,L**,XL***)\n";
open (OUTFILE3, ">"."energy_trees/branch_weights_dRMSF.txt") || die " could not open output file\n";
print OUTFILE3 "branch\t"."avgDRMSF_observed\t"."avgDRMSF_potential\t"."dRMSF_omega\t"."d_value\t"."effect_size(S,M*,L**,XL***)\n";

open (INFILE, "<"."energy_trees/myChanges.csv") || die " could not open changes list from MegaX\n";
my @IN = <INFILE>;
for (my $i = 0; $i < scalar @ALNlist; $i++){
$branch = @ALNlist[$i]; # end of branch in which change occurs
$branchbase = @ASRlist[$i]; # start of branch in which change occurs
my @avgDDG_potential = ();
my @avgDDG_observed = ();
my @avgDRMSF_potential = ();
my @avgDRMSF_observed = ();
print "collecting changes for $branch\n";     
for (my $ii = 0; $ii < scalar @IN; $ii++){
      my $INrow = $IN[$ii];
	 my @INrow = split (/,/, $INrow);
	 my $site = @INrow[0];
      my $mut = @INrow[$i];
      #print "$branch\t"."$site\t"."$mut\n";
      if ($site =~ m/\d/ && $mut ne "" && $branch ne "") {
          # lookup ddG for each site/mutation on each branch
          #print "$branch\t"."$site\t"."$mut\n";
          open (IN2, "<"."energy_trees/$branch"."_history.maestro") || die " could find corresponding maestro file\n";
          my @IN2 = <IN2>;
          for (my $j = 0; $j < scalar @IN2; $j++){
              my $INrow = $IN2[$j];
	         my @INrow = split (/\s+/, $INrow);
	         my $head = @INrow[0];
              my $ddG = @INrow[2];
              if($head != m/{}/){next;}
              @head = split(/{/, $head);
              $position = @head[0];
              $replacement = @head[1];
              $replacement = substr($replacement, 0, 1);
              $target = substr($position, 0, 1);
              $position = substr($position, 1);
              @mut = split(/\s/, $mut);
              $prior = @mut[0];
              $post = @mut[2];
              #print "maestro "."$head\t"."$position\t"."$target\t"."$replacement\t"."$ddG\t"."$site\t"."$mut\t"."$prior\t"."$post\n";
              if (abs($position - $site) <= 2 && $target eq $prior && $replacement eq $post && $ddG =~ m/\d/){   # collect obs ddG value for changes on branch
                 print "maestro "."$head\t"."$position\t"."$target\t"."$replacement\t"."$ddG\t"."$site\t"."$mut\t"."$prior\t"."$post\n";
                 $myDDG = $ddG; push(@avgDDG_observed, $ddG);}
              if (abs($position - $site) <= 2 && $ddG =~ m/\d/){   # collect avg ddG values for all possible matching site changes on branch
                 push(@avgDDG_potential, $ddG);}
              }
          close IN2;
          # compute dRMSF for each site/mutation on each branch                                                
          #if ($branch eq '' || $branchbase eq ''){$dRMSF = 0;}
          #top of branch
          open (IN3, "<"."energy_trees/$branch"."_fluct.txt"); # || die " could not find corresponding fluctuation file\n";
          my @IN3 = <IN3>;
          #bottom of branch
          open (IN4, "<"."energy_trees/$branchbase"."_fluct.txt"); # || die " could not find corresponding fluctuation file\n";
          my @IN4 = <IN4>;
          for (my $k = 0; $k < scalar @IN3; $k++){
              my $IN3row = $IN3[$k];
	         my @IN3row = split (/\s+/, $IN3row);
	         my $position3 = @IN3row[1];
              my $position3 = int($position3);
              my $value3 = @IN3row[2];
              my $IN4row = $IN4[$k];
	         my @IN4row = split (/\s+/, $IN4row);
	         my $position4 = @IN4row[1];
              my $position4 = int($position4);
              my $value4 = @IN4row[2];
              if ($site == $position3){$stopRMSF = $value3; $startRMSF = $value4; $dRMSF = abs($stopRMSF - $startRMSF);}
              #print "RMSF "."$position3\t"."$position4\t"."$startRMSF\t"."$stopRMSF\n";
              $dRMSF_allsite = abs($value3 - $value4);
              if ($dRMSF_allsite > 0){push(@avgDRMSF_potential, $dRMSF_allsite);}
              }
          close IN3;
          close IN4;
          push(@avgDRMSF_observed, $dRMSF);
          
          ### print
          if($myDDG ne ""){print OUTFILE "$branch\t"."$site\t"."$mut\t"."$myDDG\t"."$dRMSF\n";}                                                 
          }
      }
#################################################################################
# find avg ddG for all potential changes on each branch
$statSCORE = new Statistics::Descriptive::Full; # residue avg flux - reference
$statSCORE->add_data (@avgDDG_observed);
$avgDDG_observed = $statSCORE->mean();
$numDDG_observed = $statSCORE->count();
#if($numDDG_observed < $boots){$bootsYN = 'y';}
print "sample size\t"."$numDDG_observed\n";
print "avg observed ddG\t"."$avgDDG_observed\n";
$statSCORE = new Statistics::Descriptive::Full; # residue avg flux - reference
$statSCORE->add_data (@avgDDG_potential);
$numDDG_potential = $statSCORE->count();
print "sample size\t"."$numDDG_potential\n";
# signif test
open (STAT, ">"."energy_trees/$branch"."_stats_ddG_data.txt") or die "could not create stats file\n";
print STAT "ddG\t"."type\n";
@avgDDG_observed_sample = ();
@avgDDG_potential_sample = ();
if ($bootsYN eq 'n'){
for (my $i = 0; $i < scalar @avgDDG_observed; $i++){  
    $DDGobs = @avgDDG_observed[$i];
    #print "$DDGobs\t"."obs\n";
    print STAT "$DDGobs\t"."obs\n";
    $r2 = 1+rand($numDDG_potential-1); # random generator (with replacement)
    $DDGpot = @avgDDG_potential[$r2];
    #print "$DDGpot\t"."rand\n";
    print STAT "$DDGpot\t"."rand\n";
    push (@avgDDG_potential_sample, $DDGpot);
    }
}
if ($bootsYN eq 'y'){
for (my $i = 0; $i < $boots; $i++){   
    $r1 = 1+rand($numDDG_observed-1); # random generator (with replacement)
    $DDGobs = @avgDDG_observed[$r1];
    #print "$DDGobs\t"."obs\n";
    print STAT "$DDGobs\t"."obs\n";
    push (@avgDDG_observed_sample, $DDGobs);
    $r2 = 1+rand($numDDG_potential-1); # random generator (with replacement)
    $DDGpot = @avgDDG_potential[$r2];
    #print "$DDGpot\t"."rand\n";
    print STAT "$DDGpot\t"."rand\n";
    push (@avgDDG_potential_sample, $DDGpot);
    }
}
close STAT;
# find avg ddG for sampled potential changes on each branch
$statSCORE = new Statistics::Descriptive::Full; # residue avg flux - reference
$statSCORE->add_data (@avgDDG_potential_sample);
$avgDDG_potential = $statSCORE->mean();
#print @avgDDG_potential_sample;
#print "\n";
print "avg potential ddG\t"."$avgDDG_potential\n";
if ($bootsYN eq 'y'){
$statSCORE = new Statistics::Descriptive::Full; # residue avg flux - reference
$statSCORE->add_data (@avgDDG_observed_sample);
$avgDDG_observed = $statSCORE->mean();
#print @avgDDG_observed_sample;
#print "\n";
print "avg observed ddG\t"."$avgDDG_observed\n";     
}
# weight each branch for ddG  (wt = avg obs ddG / avg potential all-site ddG)
$weightDDG = (($avgDDG_observed+0.0001)/($avgDDG_potential+0.0001));
if (scalar @avgDDG_observed < 5){$weightDDG = 1;}
    
    # find statistical significance
     $sig = '';
     $p_value = 0.5;
     if (scalar @avgDDG_observed < 5){goto SKIP1;}
     open (Rinput, "| R --vanilla")||die "could not start R command line\n";
     print Rinput "library('ggplot2')\n";
     print Rinput "library('lsr')\n";
     print Rinput "data = read.table('energy_trees/$branch"."_stats_ddG_data.txt', header = TRUE)\n"; 
     $type_ddG = "data\$type"; # flux on reference residue
     $value_ddG = "data\$ddG"; # flux on query residue
     print Rinput "df = data.frame(typ=$type_ddG, val=$value_ddG)\n";
     print Rinput "print(df)\n";
     print Rinput "mytest <- t.test(val~typ, data=df)\n";
     print Rinput "print(mytest)\n";
     print Rinput "myeffect <- cohensD(val~typ, data=df)\n";
     print Rinput "print(myeffect)\n";
     print Rinput "sink('energy_trees/$branch"."_statsresult_ddG_data.txt')\n";
     print Rinput "print(df)\n";
     print Rinput "print(mytest)\n";
     print Rinput "myeffect <- cohensD(val~typ, data=df)\n";
     print Rinput "print(myeffect)\n";
     print Rinput "sink()\n";
     print Rinput "q()\n";# quit R 
     print Rinput "n\n";# save workspace image?
     close Rinput;
open (IN, "<"."energy_trees/$branch"."_statsresult_ddG_data.txt") or die "could not create stats file\n";
my @IN = <IN>;
for (my $i = 0; $i < scalar @IN; $i++){
    my $INrow = @IN[$i];
    print "$INrow\n";
    my @INrow = split(/\s+/, $INrow);
    $header = @INrow[0];
    if($header eq "t"){$p_value = @INrow[8];}
    if($p_value < 0.05){$sig = "*";}
    if($p_value < 0.01){$sig = "**";}
    if($p_value < 0.005){$sig = "***";}
}
for (my $i = 0; $i < scalar @IN; $i++){
    my $INrow = @IN[$i];
    print "$INrow\n";
    my @INrow = split(/\s+/, $INrow);
    $header = @INrow[0];
    if($header eq "[1]"){$d_value = @INrow[1];}
    $effect = "***"; $Dval = 1;
    if($d_value < 0.8){$effect = "**"; $Dval = $d_value;}
    if($d_value < 0.5){$effect = "*"; $Dval = $d_value;}
    if($d_value < 0.2){$effect = ""; $Dval = $d_value;}
}
close IN;
SKIP1:
print "branch and ddG weight\n";
print "$branch\t"."$weightDDG"."$sig\t"."$Dval\t"."$effect\t";
print OUTFILE2 "$branch\t"."$avgDDG_observed\t"."$avgDDG_potential\t"."$weightDDG\t"."$Dval"."$effect\n";
#################################################################################
# find avg dRMSF for all potential changes on each branch
$statSCORE = new Statistics::Descriptive::Full; # residue avg flux - reference
$statSCORE->add_data (@avgDRMSF_observed);
$avgDRMSF_observed = $statSCORE->mean();
$numDRMSF_observed = $statSCORE->count();
#if($numDRMSF_observed < $boots){$bootsYN = 'y';}
print "sample size\t"."$numDRMSF_observed\n";
print "avg observed dRMSF\t"."$avgDRMSF_observed\n";
# find avg dRMSF for all potential changes on each branch
$statSCORE = new Statistics::Descriptive::Full; # residue avg flux - reference
$statSCORE->add_data (@avgDRMSF_potential);
$numDRMSF_potential = $statSCORE->count();
print "sample size\t"."$numDRMSF_potential\n";
# signif test
open (STAT, ">"."energy_trees/$branch"."_stats_dRMSF_data.txt") or die "could not create stats file\n";
print STAT "dRMSF\t"."type\n";
@avgDRMSF_potential_sample = ();
@avgDRMSF_observed_sample = ();
#for (my $i = 0; $i < scalar @avgDRMSF_observed; $i++){
if ($bootsYN eq 'n'){
for (my $i = 0; $i < scalar @avgDRMSF_observed; $i++){     
    $DRMSFobs = @avgDRMSF_observed[$i];
    print STAT "$DRMSFobs\t"."obs\n";
    $r2 = 1+rand($numDRMSF_potential-1); # random generator (with replacement)
    $DRMSFpot = @avgDRMSF_potential[$r2];
    print STAT "$DRMSFpot\t"."rand\n";
    push (@avgDRMSF_potential_sample, $DRMSFpot);
    }
}
if ($bootsYN eq 'y'){
for (my $i = 0; $i < $boots; $i++){     
    $r1 = 1+rand($numDRMSF_observed-1); # random generator (with replacement)
    $DRMSFobs = @avgDRMSF_observed[$r1];
    print STAT "$DRMSFobs\t"."obs\n";
    push (@avgDRMSF_observed_sample, $DRMSFobs);
    $r2 = 1+rand($numDRMSF_potential-1); # random generator (with replacement)
    $DRMSFpot = @avgDRMSF_potential[$r2];
    print STAT "$DRMSFpot\t"."rand\n";
    push (@avgDRMSF_potential_sample, $DRMSFpot);
    }
}
close STAT;
# find avg dRMSF for sampled potential changes on each branch
$statSCORE = new Statistics::Descriptive::Full; # residue avg flux - reference
$statSCORE->add_data (@avgDRMSF_potential_sample);
$avgDRMSF_potential = $statSCORE->mean();
print "avg potential dRMSF\t"."$avgDRMSF_potential\n";
if ($bootsYN eq 'y'){
$statSCORE = new Statistics::Descriptive::Full; # residue avg flux - reference
$statSCORE->add_data (@avgDRMSF_observed_sample);
$avgDRMSF_observed = $statSCORE->mean();
print "avg observed dRMSF\t"."$avgDRMSF_observed\n";     
}
# signif test     
# weight each branch for dRMSF  (wt = avg obs dRMSF / avg potential all-site dRMSF)
$weightDRMSF = (($avgDRMSF_observed+0.0001)/($avgDRMSF_potential+0.0001));
if (scalar @avgDRMSF_observed < 5){$weightDRMSF = 1;}

     # find statistical significance
     $sig = '';
     $p_value = 0.5;
     if (scalar @avgDRMSF_observed < 5){goto SKIP2;}
     open (Rinput, "| R --vanilla")||die "could not start R command line\n";
     print Rinput "library('ggplot2')\n";
     print Rinput "library('lsr')\n";
     print Rinput "data = read.table('energy_trees/$branch"."_stats_dRMSF_data.txt', header = TRUE)\n"; 
     $type_dRMSF = "data\$type"; # flux on reference residue
     $value_dRMSF = "data\$dRMSF"; # flux on query residue
     print Rinput "df = data.frame(typ=$type_dRMSF, val=$value_dRMSF)\n";
     print Rinput "print(df)\n";
     print Rinput "mytest <- t.test(val~typ, data=df)\n";
     print Rinput "print(mytest)\n";
     print Rinput "myeffect <- cohensD(val~typ, data=df)\n";
     print Rinput "print(myeffect)\n";
     print Rinput "sink('energy_trees/$branch"."_statsresult_dRMSF_data.txt')\n";
     print Rinput "print(df)\n";
     print Rinput "print(mytest)\n";
     print Rinput "myeffect <- cohensD(val~typ, data=df)\n";
     print Rinput "print(myeffect)\n";
     print Rinput "sink()\n";
     print Rinput "q()\n";# quit R 
     print Rinput "n\n";# save workspace image?
     close Rinput;
open (IN, "<"."energy_trees/$branch"."_statsresult_dRMSF_data.txt") or die "could not create stats file\n";
my @IN = <IN>;
for (my $i = 0; $i < scalar @IN; $i++){
    my $INrow = @IN[$i];
    print "$INrow\n";
    my @INrow = split(/\s+/, $INrow);
    $header = @INrow[0];
    if($header eq "t"){$p_value = @INrow[8];}
    if($p_value < 0.05){$sig = "*";}
    if($p_value < 0.01){$sig = "**";}
    if($p_value < 0.005){$sig = "***";}
}
for (my $i = 0; $i < scalar @IN; $i++){
    my $INrow = @IN[$i];
    print "$INrow\n";
    my @INrow = split(/\s+/, $INrow);
    $header = @INrow[0];
    if($header eq "[1]"){$d_value = @INrow[1];}
    $effect = "***"; $Dval = 1;
    if($d_value < 0.8){$effect = "**"; $Dval = $d_value;}
    if($d_value < 0.5){$effect = "*"; $Dval = $d_value;}
    if($d_value < 0.2){$effect = ""; $Dval = $d_value;}
}
close IN;
SKIP2:     
print "branch and dRMSF weight\n";
print "$branch\t"."$weightDRMSF"."$sig\t"."$Dval\t"."$effect\n";
print OUTFILE3 "$branch\t"."$avgDRMSF_observed\t"."$avgDRMSF_potential\t"."$weightDRMSF\t"."$Dval"."$effect\n";
#################################################################################
}
close OUTFILE;
close OUTFILE2;
close INFILE;
#################################################################################
### make energy weighted trees
system "gedit energy_trees/branch_weights_ddG.txt energy_trees/branch_weights_dRMSF.txt energy_trees/myTree.nwk $clustalID.aln";
print "\nmultiply branch lengths in tree by either the ddg or dRMSF weights provided\n";
print "\nresave then open and view your trees in MEGAX or https://icytree.org\n\n";
system "megax";
system "xdg-open https://icytree.org";
# recompute and save ddG .nwk file
# recompute and save dRMSF .nwk file
exit;




