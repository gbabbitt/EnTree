#!/usr/bin/perl

#use strict;
#use warnings;
use feature ":5.10";
use File::Copy;

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
print "path to Chimera .exe\t"."$chimera_path\n";
print "path to ChimeraX .exe\t"."$chimerax_path\n";
print "\nFILES IN DIRECTORY\n";
$dir = "pdb_mutants_final"; opendir(DIR,$dir) or die "can't open directory $dir:$!"; print"\n";
while ($filename = readdir DIR){ # loop through files
  print "filename is "."$filename\n";
  }

# prompt user 
sleep(1);print "\nType PDB ID for reference protein OR one of the variants (e.g. 1rex)\n\n";
my $pdbID = <STDIN>;
chop($pdbID);
sleep(1);print "\nType length of protein (i.e. number of sites in PDB file)\n\n";
my $lengthID = <STDIN>;
chop($lengthID);

###############################################################
print("Preparing display...\n");
print("close ChimeraX program to exit\n\n");
# copy visualization support files to folder
mkdir("ChimeraXvis");
#copy("./pdb_mutants_final/final_$pdbID".".pdb", "ChimeraXvis/reference.pdb") || die "could not find ./pdb_mutants_final/final_$pdbID"."pdb\n";
#copy("./attribute_files/attr_ddG_$pdbID"."_singlepoint.maestro.dat", "ChimeraXvis/attributeDGG.dat") || die "could not find ./attribute_files/attr_ddG_$pdbID"."_singlepoint.maestro.dat\n" ;
# create control file for visualization
open(CTL, ">"."ChimeraXvis.ctl");
print CTL "model\t"."#1\n";
#print CTL "chain\t"."/$chainMAP\n";
print CTL "structure\t"."ChimeraXvis/reference.pdb\n";
print CTL "structureADD\t"."ChimeraXvis/query.pdb\n";
print CTL "attr_file\t"."ChimeraXvis/attributeDGG.dat\n";
print CTL "length\t"."$lengthID\n";
print CTL "attr\t"."ddG\n";
#print CTL "minval\t"."-1\n";
#print CTL "maxval\t"."5\n";
print CTL "palette\t"."YlOrRd\n";
print CTL "lighting\t"."soft\n";
print CTL "transparency\t"."70\n";
print CTL "background\t"."gray\n";
close CTL;
##############################################################
print "\nScale of ddG is YELLOW = NO EFFECT to RED = LARGE EFFECT\n\n";
system "$chimerax_path"."ChimeraX color_by_attr_chimerax_protein.py\n";
print "\nScale of ddG is YELLOW = NO EFFECT to RED = LARGE EFFECT\n\n";
