Usage
=====

MAESTRO is a command line tool and either scores a given 3D structure or 
predicts changes in stability upon point mutations. Scoring is the default mode 
and is optimized for the evaluation of X-ray, NMR or predicted models. The 
mutation mode includes two options: (a) the evaluation of the impact of given 
point mutations on the protein stability, or (b) scanning the given protein for
the most (de)stabilizing point mutations. This is reflected in the command line 
options '--evalmut' and '--scanmut'.


Structure scoring and stability change prediction:
--------------------------------------------------

For working on a single molecule use:

maestro <configuration file> <pdb file|pdb id>[,chains[,model]] 
                            [--evalmut="mutstring"] [--bu] 
                            [--ph="pH value"]
    
For working with a list of molecules and/or mutations:

maestro <configuration file> --scorelist=<pdb list> [--bu]

maestro <configuration file> --evalmutlist=<mutant list> [--bu] 
                           [--ph="pH value"|--ph_column="column index"]


With the option '--bu', MAESTRO treats the given pdb structure(s) as biological 
assemblies (see section 2a for more details). In case of a stability change 
prediction, the pH value can be set with option '--ph' (default = 7.0).

Scan for mutations and disulfide bond prediction:
-------------------------------------------------

maestro <configuration file> --scanmut=<scan options file> 
                            [--nthread=<number of max. threads>]

As the scanning process can be controlled in many aspects, the options need to
be given in a file. 


Content
=======
1)  Configuration File

2)  Structure scoring and stability change prediction
2a) PDB file, PDB ID, PDB Lists and biological assemblies 
2b) Evaluating mutations (mutation string)
2c) Output

3)  Scan for mutations
3a) Scanning algorithms
3b) Scan options file
3c) Output

4)  Disulfide bond prediction
4a) Scan option file
4b) Output


1) Configuration file
*********************

The xml-based MAESTRO configuration file defines several parameters (e.g. energy
functions, ddG predictors) and is a required option. Note that the location of
all MAESTRO data files is determined by the location of the configuration file. 
I.e. the subdir 'effiles' must be located in the same folder as the 
configuration file.

Be aware that changing the elements 'energy_functions' and 'ddg_council' may 
have a negative influence on the prediction power of MAESTRO.

Within the section 'evaluate' multiple search paths for pdb files can be 
defined, which are searched in the order of their appearance in the xml file.

Each search path ('pdbhome') element consists of several attributes: 
dir     ... directory / path
prefix  ... filename prefix, e.g. 'pdb', default = ''
postfix ... filename postfix, e.g. '.ent.gz', default = ''
tolower ... 'true' if the filenames in your local pdb directory consists 
            of lower case letters and the given ID should be converted to
            lower case. default = 'false'
toupper ... like tolower, but in case of filenames in upper case.
bu      ... 'true' if the directory contains biological assemblies, 
            default='false'

IMPORTANT REMARK: by default (if option --bu is omitted), directories marked
with " bu='true' " are not being searched for matching files. Only biological
assemblies should be stored there. Everything else should go to the normal pdb
homes.

Example for non-biological-assembly pdb files:
 
<pdbhome dir='/home/bill/pdb/', prefix='pdb' postfix='.ent.gz' tolower='true',
         bu='false' />

Here, MAESTRO will convert a given pdb ID '1BV1' as follows: 
/home/bill/pdb/pdb<pdb-id>.ent.gz  -> /home/bill/pdb/pdb1bv1.ent.gz


2) Structure scoring and stability change prediction
****************************************************

2a) PDB file, PDB ID, or Lists
==============================
The second mandatory argument of MAESTRO is either a pdb file name, a pdb ID,
pdb list, or list of mutants. 

PDB file or PDB ID
------------------

On execution, MAESTRO applies the following search rules:

First, the given argument is considered to be a valid file name of a pdb style
file. If a file with this name does NOT exist, MAESTRO interprets the name as a 
pdb ID and expands it according to the <pdbhome>...</pdbhome> entries in the 
configuration file. Then, MAESTRO performs a prediction on all matching files.

Examples:
maestro config.xml /home/bill/pdb/pdb1bv1.ent.gz
maestro config.xml 1BV1

In the first example an existing file is given. MAESTRO starts a
prediction based on this file. In the second example, we assume that
MAESTRO cannot find a file named '1BV1'. Then the argument is
interpreted as an identifier and MAESTRO starts a search in each search
path ('pdbhome'). Based on the example given in the section before,
MAESTRO transforms '1BV1' to '/home/bill/pdb/pdb1bv1.ent.gz'.

For both, PDB file and identifier, chains and a model number can be defined by
appending them to the filename/ID separated by a comma: 

Examples:
(1) maestro config.xml /home/bill/pdb/pdb2hhb.ent.gz,AB
(2) maestro config.xml 1BTV,A
(3) maestro config.xml 1BTV,A,1
(4) maestro config.xml 1BTV,,1
(5) maestro config.xml 1BTV,,f

In the first example MAESTRO evaluates the complex formed by chain A and B of
2hhb. 1BTV is an NMR structure. If no model number is given (2nd example), 
MAESTRO runs the prediction for each model, but only for the given chains. In 
example 3 only model number 1 of chain A is considered.  If no chain is set, but
a model number (example 4), all chains from the given model will be used. With 
'f' instead of a model number, as in the last example, only the first model 
(regardless of its model number in the pdb file) is used.

Biological assemblies (biological units):
-----------------------------------------

In PDB, the biological assembly is constructed out of crystallographic or
NMR data. In this case, the MODEL qualifier within a PDB file is used to mark
subunits of the respective assemblies. The biological assembly is the union of
all models.

In this context, the '--bu' option tells MAESTRO 

a) to interpret the MODELs in the given pdb as subunits of the complex (i.e. the
   finally evaluated structure is the union of all MODELs)

b) to consult those pdb directories given in the configuration file which have
   the attribute "bu='true'" and skip the others.


Example: 

maestro config.xml /home/bill/biounits/1bv1.pdb1.gz --bu

This is equivalent to

maestro config.xml 1bv1 --bu

given that config.xml has the entry:

<pdbhome dir='/home/bill/biounits/' , prefix=''
         postfix='.pdb1.gz' tolower='true' , bu='true' />



Pdb lists
---------

Alternatively to a single pdb ID or file-name, a file containing a list of
IDs/file-names can be given with option '--pdblist'. The list file must contain
one ID or file-name per line. Each ID/file-name is processed as described above.


2b) Evaluating mutations
========================

Given the option "--evalmut=<mutation-string>", MAESTRO sets the given mutation
and evaluates their impact on the protein stability. Because the string may 
contain shell meta characters, we recommend to embed it in single quotes 
(Windows: double quotes) , e.g.:

--evalmut='I102.A{L}' (Windows: --evalmut="I102.A{L}")

The format of the string is:

"<wild type amino acid><residue id[icode]>[.chains]{<substitutions>}"

+wild type amino acid: is used to check if the given amino acid type match the
                       type of the residue in the PDB structure.
                      
+residue id and insertion code: defines the residue.

+chain: defines the chains which should be affected by the substitutions. This
        parameter is optional in the case of monomeric or homo-multimeric 
        structures. It is also possible to define more than one chain: e.g. 
        I102.ACE{L}. n case of homologous chains, a substitution is auto-
        matically established to all homologous chains. E.g. hemoglobin consists
        of two alpha (A,C) and two beta chains (B,D). Indicating just 'A' in the
        mutation string will automatically introduce the mutation also in chain
        'C'.

+substitutions: a single substitutions or a list, see below.

Examples:
(1) I102.A{L}
(2) I102.A{A,L,P}

(1) exchange ILE at position 102 in chain A to LEU
(2) exchange ILE at position 102 in chain A to ALA, LEU and PRO

As the second example suggests it is possible to define multiple substitutions 
per residue. Furthermore, instead of the single letter code of the 20 standard
amino acids, one or more of the following group definitions can be used: 

XAA, UNK or X ... Unspecified or unknown amino acid (all 20 amino acids)
ASX or B      ... Asparagine or aspartic acid (ASN, ASP)
GLX or Z      ... Glutamine or glutamic acid (GLN, GLU)
XLE or J      ... Leucine or Isoleucine (ILE, LEU)

HYDROPHOBIC   ... Hydrophobic (ALA, CYS, GLY, ILE, LEU, MET, PHE, PRO, TRP, VAL)
POLAR         ... Polar (ASP, GLU, ARG, LYS, HIS, ASN, GLN, SER, THR, TYR)

AROMATIC      ... Aromatic (HIS, PHE, TRP, TYR)
ALIPHATIC     ... Aliphatic (ALA, GLY, ILE, LEU, MET, PRO, VAL)

CHARGED       ... Charged (ARG, HIS, LYS, ASP, GLU)
POSITIVE      ... Positive (ARG, HIS, LYS)
NEGATIVE      ... Negative (ASP, GLU)

SULPHURCONT   ... Sulphur Containing (MET, CYS)

TINY          ... Tiny (ALA, CYS, GLY, SER)
SMALL         ... Small (ASN, ASP, PRO, THR, VAL)
LARGE         ... Large (ARG, GLN, GLU, HIS, ILE, LEU, LYS, MET, PHE, TRP, TYR)

Example: 
I102.A{TINY,H} == I102.A{A,G,C,S,H}

MAESTRO also supports multiple point mutations. Simple extend the substitution
string, separated by a comma.

Examples: 
I102.A{L},L114.A{I} 
I102.A{TINY},L114.A{I,K}

If more than one substitution are given for one residue (as it is the case in 
the second example), all possible combinations will be calculated. In this case: 

I102.A{A},L114.A{I}
I102.A{A},L114.A{K}
I102.A{G},L114.A{I}
I102.A{G},L114.A{K}
I102.A{C},L114.A{I}
I102.A{C},L114.A{K}
I102.A{S},L114.A{I}
I102.A{S},L114.A{K}


2c) Output:
===========
MAESTRO provides a csv-formatted output. For model scoring the output starts 
with the header line:

#structure<TAB>seqlength<TAB>score

Followed by the tab-separated results. E.g.: 

../pdb1bv1.ent.gz,A,-<TAB>159<TAB>-2.37554

In case of predicted stability changes, the output is extended by the 
differences of energy and score relative to the wild type and the predicted ddG
value (kCal/mol), based on multiple machine learning agents and a confidence 
estimation (second value, ranging from 0 to 1, where 1 indicates highest 
confidence). Note that negative ddG values indicates stabilization, positive 
values destabilization. The output starts again with a header line:

#structure<TAB>seqlength<TAB>mutation<TAB>score<TAB>delta_score<TAB>ddG<TAB>ddG_confidence

Followed by the tab-separated results:
../pdb1bv1.ent.gz,A,-<TAB>159<TAB>wildtype<TAB>-2.795186<TAB>0.000000<TAB>0.000000<TAB>1.000000
../pdb1bv1.ent.gz,A,-<TAB>159<TAB>I102.A{A}<TAB>-2.500751<TAB>0.294435<TAB>2.579110<TAB>0.925501

MAESTRO allows the evaluation of multiple molecules in a single run. In this
case the molecule names and the corresponding mutations can be supplied in a 
file using the option --evalmutlist. The file format is:

PDB1<TAB>mutstring[<TAB>pH]
PDB2<TAB>mutstring[<TAB>pH]
...

For example:
1BV1<TAB>I102.A{H}<TAB>5.0
1BTV<TAB>I102.A{C},V23.A{C}<TAB>6.7

If the file provides pH values for the single mutants, the corresponding column
can be set with option --ph_column=<column index>. In the above example the 
column index is 3.

The list files supplied with --scorelist or --evalmutlist can have additional 
tab delimited columns. However, --scorelist reads only the first one, 
--evalmutlist reads only the first, the second and, in case of a given column 
index, the pH column.

Output Options
--------------

--energy ... the raw MAESTRO 'energy' is printed in addition to the score.

--json ...  JSON-formatted output

--resultfile=<FILE NAME> ... the output is redirected to the given file.
  


3) Scan for mutations
*********************

Besides the scoring and stability change prediction of defined mutations, 
MAESTRO provides a scan for stabilizing and destabilizing mutation for a given 
protein structure.

A scan for mutations experiment is configured via an XML-file and called with 
the option '--scanmut=<scan options file>'. The options file allows the 
specification of mutation constraints as well as the definition of an algorithm
and its options.

With option '--nthread=<number of max. threads>' the maximum number of threads 
used for a mutation scan can be defined (default = 1). 

3a) Search algorithms
=====================

Three different search algorithms are implemented: 

- Optimal search 
- Greedy search
- Evolutionary algorithm

In principle, an arbitrary number of mutation sites can be specified. However, 
the number of mutation sites increases the computation time exponentially for
an optimal search.

Optimal search:
---------------

In case of an optimal search, all possible point mutations and all possible 
combinations of them are calculated. For each of these combinations a score is
calculated and the stability change is predicted. 

This approach guarantees optimal (de-)stabilizing predicted combination, but is
very time-consuming. For example for the PDB structure 1BV1 (159 residues), no
restrictions regarding the type of mutation and three mutation sites 
approximately 4.51e9 possible combinations have to be tested which results in 
a run time of about 500 days on a standard PC.

Greedy search:
--------------

The greedy search is an iterative approach. In each iteration a mutant is 
extended by the most (de-)stabilizing point mutation, in combination with the
mutations found in the iterations before. 

This algorithm is fast in comparison to the optimal search, but cannot guarantee
the detection of the most (de-)stabilizing mutant.

Evolutionary algorithm:
-----------------------

In the evolutionary algorithm (EA) the introduced point mutations are encoded
in the EA's genes. Each individual then represents a certain combination of 
point mutation. The fitness function is based on the ddG prediction. On the 
individuals the EA standard operation reproduction, mutation, recombination, 
selection and migration are applied. The EA parameters can be set in the 
options file.

Like the greedy search, this approach cannot guarantee the detection of the most 
(de-)stabilizing mutant. But the EA usually performs better than the greedy 
search.
 

3b) Scan options file
=====================

The scan options file consists of three main sections: (i) a general section, 
(ii) a constraint section, and (iii) an algorithm specific section.

In the general section, the type of the simulation, input and output options
can be defined. The following elements are available:

<type> ... allowed values: 'stabilize' or 'destabilize' (default)
         In case of 'stabilize', MAESTRO search for the most stabilizing 
         combinations of point mutations. In case of 'destabilize', for the 
         most destabilizing ones.

<selection_base> ... allowed values: 'score' or 'ddg' (default)
         This element defines if the selection of a mutant should be based on 
         it's comb_score or the predicted ddg value.
         
<pdb> ... allowed values: pdb formatted file (no defaults)
         In addition to the filename, this element provides the attributes
         model, chain, and bu: 
         model ... model number, which should be used for the scan. 
                   If the attribute is not set, the first model is used.
         chain ... Defines the chains, which should be included. If the 
                   attribute is not set or set to '*' all chains within 
                   the selected model are included. 
         bu ... if this attribute is set to 'true', MAESTRO treats the given 
                pdb as biological assembly (merge of all models). If the 
                attribute is not set or is set to 'false', the pdb is treated
                as asymmetric unit.

<ph> ... allowed values: real number {0.0, ..., 14.0} (default=7.0)
         Defines the pH value for the experiment.

<output> ... within the output element three elements can be defined:
         <resultfile> ... defines the name of the result file. If no result
                   file is set, the results are printed to the standard out.
                   In addition, this element supports the attribute 'json'.
                   json ... allowed values: 'true' and 'false' (default). 
                            Set this attribute true if the output should be
                            JSON-formatted.
         <historyfile> ... defines the name of a history file. If no history
                   file is set, the history is printed to the standard out.
         <top_mutants> ... defines the number of the top mutants, which should 
                   be printed in the final result (resultfile).
         <singlepoint> ... defines the name of a single point statistics file. 
                   The file contains the prediction values for all allowed 
                   single point mutations per residue.            

In the constraints section, mutagenesis constraints, like the number of maximum 
mutations or the allowed substitutions, can be defined. The following elements
are available within the '<constraints>' element:

<max_mutation> ... allowed values: integer greater than 0 (default=3).
         Defines the maximum number of mutation sites within one mutant.

<residue_mask> ... allowed values: a comma separated list of residues or residue
         ranges. 
         Defines the residues which should be included in the mutagenesis 
         experiment. A residue need to be defined in the following format: 
            [<wild type amino acid>]<residue id[icode]>[.chains]
         The wild type amino acid and chains options are optional.
         Example: 103.AB,177-182,10,22.B

<residue_exclusion> ... allowed values: a comma separated list of residues.
         Defines the residues which should be excluded in the mutagenesis 
         experiment. Same formatting rules as in the residue mask.

<aa_mut_inclusion> ... allowed values: a comma separated list of one-letter AA 
         codes. Defines the substitutions which are allowed. If the element is 
         empty or missing, all possible substitutions are allowed.

<aa_wt_inclusion> ... allowed values: a comma separated list of one-letter AA 
         codes. Alternative definition of residues which should be included in 
         the mutagenesis experiment, based on the wild type AA type.

<aa_mut_exclusion> ...  allowed values: a comma separated list of one-letter AA
         codes. Defines substitutions which are not allowed. If the element is
         empty or missing, all possible substitutions are allowed.
         
<aa_wt_exclusion> ...  allowed values: a comma separated list of one-letter AA
         codes. Alternative definition of residues which should be excluded in 
         the mutagenesis experiment, based on the wild type AA type.
         
<mutationstring> ... allowed values: mutation string (see section 2c).
         Defines allowed mutations. This option overwrites the options set with 
         the elements: residue_mask, residue_exclusion, aa_mut_inclusion, 
         aa_wt_inclusion, aa_mut_exclusion, and aa_wt_exclusion.

<asa> ... allowed values: 'buried' or 'exposed'
         Activates the ASA filter, which includes either only exposed or only 
         buried residues from the experiment.
         Attributes: probe ... probe size for ASA prediction; allowed values: 
                               float value between 0.1 and 2.5; default = 1.4
                     type ... defines if the ASA is defined in square angstroms
                              (absolute) or as relative value; allowed values:
                              'absolute', 'relative'; default = 'relative'
                     cutoff ... defines the selection cutoff; float; default = 
                                0.3 (relative) or 30.0 (absolute)
         
The final section defines the mutagenesis method. The available options depend
on the chosen method: 

Optimal search: <mutator type='optimal'> ... no additional options available.

Greedy search: <mutator type='greedy'> ... available options: number_top.
         
         <number_top> ... allowed values: integer greater than 0 (default=1).
                   Defines the number of top scoring mutants, which should be 
                   passed to the next iteration.
 
Evolutionary algorithm: <mutator type='ea'> ... available options: 
         npopulations, ngenerations, population_size, mutation_rate, 
         and migration_rate. 
         
         <npopulations> ... allowed values: integer greater than 0 (default=2).
                   Defines the number of populations in the EA-simulation. 
         <ngenerations> ... allowed values: integer greater than 0 
                   (default=100). Defines the number of generations in the
                   EA-simulation. 
         <population_size> ... allowed values: integer greater than 1
                   (default=100). Defines the number of individuals per 
                   population. 
         <mutation_rate> ... allowed values: real number {0.0, ..., 1.0}
                   (default=0.1). Defines the mutation probability within a 
                   population. A mutation rate of 0.1 means that in average 
                   10% of the individuals are mutated after crossover.
         <migration_rate> ... allowed values: real number {0.0, ..., 1.0}
                   (default=0.1). Defines the migration probability within 
                   one generation. 
         
Examples:
---------

Optimal search:
-search for destabilizing mutations
-based on mutation string, only mutate the residues 103,40,16, and 108
-find a combination with maximal two point mutations

<?xml version="1.0" encoding="UTF-8"?>
<mutation_experiment>
    <type>destabilize</type>
    <pdb chain='A'>1bv1.pdb</pdb>
    <ph>6.9</ph>
    <output>
        <resultfile>mutresults.tab</resultfile>
        <historyfile>history.txt</historyfile>
        <singlepoint>singlepoint.txt</singlepoint>
        <top_mutants>10</top_mutants>
    </output>
    <constraints>
      <mutationstring>K103.A{X},S40{I,L,Q},A16{V,R,Q},P108{X}</mutationstring>
      <max_mutation>2</max_mutation>
    </constraints>
    <mutator type='optimal'>
    </mutator>
</mutation_experiment>



Greedy search: 
-search for stabilizing mutations
-do not substitute with P or C
-include only exposed residues
-find a combination with maximal three point mutations
-pass the two most stabilizing mutations to the next iteration

<?xml version="1.0" encoding="UTF-8"?>
<mutation_experiment>
    <type>stabilize</type>
    <pdb chain='A' bu='false'>1bv1.pdb</pdb>
    <output>
        <resultfile>mutresults.tab</resultfile>
        <historyfile>history.txt</historyfile>
        <top_mutants>100</top_mutants>
    </output>
    <constraints>
       <aa_mut_exclusion>P,C</aa_mut_exclusion>
       <max_mutation>3</max_mutation>
       <asa probe='1.4' type='absolute' cutoff='50'>exposed</asa>
    </constraints>
    <mutator type='greedy'>
        <number_top>2</number_top>
    </mutator>
</mutation_experiment>



Evolutionary algorithm:
-search for stabilizing mutations
-do not substitute with C
-allow mutations at all positions between 10 and 149, except the residues 80-87
-find a combination with maximal three point mutations

<?xml version="1.0" encoding="UTF-8"?>
<mutation_experiment>
    <type>stabilize</type>
    <pdb model='' chain='*' bu='false'>1bv1.pdb</pdb>
    <output>
        <resultfile>mutresults.tab</resultfile>
        <historyfile>history.txt</historyfile>
        <top_mutants>100</top_mutants>
    </output>
    <constraints>
       <aa_mut_exclusion>C</aa_mut_exclusion>
       <residue_mask>10-149</residue_mask>
       <residue_exclusion>80-87</residue_exclusion>
       <max_mutation>3</max_mutation>
    </constraints>
    <mutator type='ea'>
         <npopulations>3</npopulations> 
         <ngenerations>200</ngenerations> 
         <population_size>100</population_size>
         <mutation_rate>0.05</mutation_rate>
         <migration_rate>0.01</migration_rate> 
    </mutator>
</mutation_experiment>


3c) Output
==========

As already mentioned above, MAESTRO provides two output files: (i) The history
file contains interim results and some additional information. (ii) The result
file contains the final result.

Result file:
------------
The result file starts with a short summary about the mutagenesis experiment, 
followed by the top scoring mutants, delta score, the predicted stability 
change in comparison to the wild type (kCal/mol), and the prediction confidence 
estimation (ranging from 0 to 1, where 1 indicates highest confidence). The 
order depends on the experiment type (de-/stabilize) and the selection base 
(score/ddg). Both can be defined in the mutagenesis configuration file (see 
above).   
  
History file:
-------------
As the result file, the history file starts with a short summary. Followed by
a list of allowed point mutations, based on the constraints given in the 
mutagenesis configuration file. Followed by all mutants found during the 
mutagenesis experiment, including their stability change predictions and 
delta scores. In case of the evolutionary algorithm, the list is interrupted
by short generation/population summaries. In case of the greedy search, the 
list is grouped by the iteration. The history file closes with a short
statistics about the possible single point mutations.


4)  Disulfide bond prediction
*****************************

MAESTRO provides a special scan mode for the prediction of suitable disulfide 
bonds to stabilize a protein structure.  

As the standard scan for mutations, a scan for disulfide bonds is configured 
via an XML-file and called with the option '--scanmut=<scan options file>'. 
The options file allows the specification of mutation constraints.


4a) Scan option file
====================

The general and constraint options are equal to the options for the standard 
mutation scan (see section 3b). Only the search algorithm has to be set to 
'ssbond': 

<mutator type='ssbond'>

Example:
--------

<?xml version="1.0" encoding="UTF-8"?>
<mutation_experiment>
  <pdb bu="false">pdb1xnb.ent.gz</pdb>
  <selection_base>ddg</selection_base>
  <output>
    <resultfile>1xnb.res.tab</resultfile>
    <historyfile>history.txt</historyfile>
  </output>
  <constraints></constraints>
  <mutator type="ssbond"></mutator>
</mutation_experiment>


4b) Output
==========

The result file is based on the format described in section 4c, extended by 
penalty values and the disulfide bond score. The predictions are sorted by 
the disulfide bond score from best (most negative score) to worst.
