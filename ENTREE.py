
#!/usr/bin/env python
import os
import re
from kivy.app import App
from kivy.uix.widget import Widget
from kivy.properties import ObjectProperty

print("Welcome to EnTree - thermodynamic estimation of the evolutionary process")
cmd = 'gedit READMEentree.md'
os.system(cmd)

# create fasta format
print("converting to fasta...")
cmd = 'perl PATHS.pl'
os.system(cmd)

# create fasta format
print("converting to fasta...")
cmd = 'perl convertALN.pl'
os.system(cmd)

print("Opening MegaX...")
print("(0) open your .aln converting it to .meg")
print("NOTE: if conversion fails, open from a multiple fasta format instead")
print("(1) select best protein evolution model and generate tree")
print("(2) save tree in newick format as 'myTree.nwk'")
print("(3) reconstruct ancestral states on tree")
print("(4) generate list of changes saved as 'myChanges.csv'")
print("(5) generate most prob ancestral seq reconstruction saved as 'myASR.txt'")
cmd = 'megax'
os.system(cmd)

# add ASR to .aln and .fasta files
print("Adding ASR to your original clustal alignment...")
cmd = 'perl formatASR.pl'
os.system(cmd)



class ENTREEApp(App):
#    kv_directory = 'kivy_templates'
    def build(self):
        return MyLayout()
   
class MyLayout(Widget):
    
      
    # define buttons and actions
    
    def btn1(self):
        print("running PDBmutator - variants from protein alignment") 
        cmd = 'perl PDBmutator.pl'
        os.system(cmd)
    def btn2(self):
        print("running AMBER MD") 
        cmd = 'perl AMBERMD.py'
        os.system(cmd)
    def btn3(self):
        print("running MAESTRO")
        # read MD ctl file
        infile = open("paths.ctl", "r")
        infile_lines = infile.readlines()
        print len(infile_lines)
        for x in range(len(infile_lines)):
            infile_line = infile_lines[x]
            print(infile_line)
            infile_line_array = re.split('\s+', infile_line)
            header = infile_line_array[0]
            value = infile_line_array[1]
            print(header)
            print(value)
            if(header == "maestro_path"):
                PATHid = value
                print("my path is",PATHid)
        # run maestro
        cmd = 'python3 batch_maestro.py '+PATHid+'/pdb_mutants_final'
        print(cmd)
        os.system(cmd)
    def btn4(self):
        print("running mapping in ChimeraX") 
        cmd = 'perl mapping.pl'
        os.system(cmd)
    def btn5(self):
        print("creating ddG and dRMSF trees")
        cmd = 'perl ddGtree.pl'
        os.system(cmd)

if __name__ == '__main__':
    ENTREEApp().run()
