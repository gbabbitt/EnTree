import subprocess
import sys
from os import path

def call_megax():
    print("[evolMAESTRO/build_tree] MEGA-X will now be opened so you can define your phylogenetic tree building specifications")
    print("[evolMAESTRO/build_tree] 1) Click the small blue PROTOTYPE button at the bottom right")
    print("[evolMAESTRO/build_tree] 2) Specify \"Protein(Amino Acid)\" in the MX: Prototyper Data Type window")
    print("[evolMAESTRO/build_tree] 3) Click PHYLOGENY at the top menu, specify Neighbor-Joining (Faster) or Maximum Likelihood tree generation method (Slower, more exhaustive)")
    print("[evolMAESTRO/build_tree] 4) Indicate model and number of threads to be used for tree generation, as well as any other options tailored to your use case or use defaults")
    print("[evolMAESTRO/build_tree] 5) Save the .mao file in the same folder as your evolMAESTRO run")
    print("[evolMAESTRO/build_tree] 6) Exit MEGA to continue evolMAESTRO")
    input("[evolMAESTRO/build_tree] ...Press Enter to continue")
    subprocess.check_output("megax", stderr=subprocess.STDOUT, shell=True)
    maofilename = input("[evolMAESTRO] Enter the name of the .mao file to continue...\n")
        
    if path.exists(maofilename):
        mega_cmd = "megacc -a " + maofilename + " -d " + sys.argv[1] + " -o mega.nwk"
        print("[evolMAESTRO/build_tree] Building phylogenetic tree...")
        subprocess.check_output(mega_cmd, stderr=subprocess.STDOUT, shell=True)
    else:
        print("[evolMAESTRO/build_tree] .mao file not found. Please re-run from the tree building module and ensure the .mao file is in the evolMAESTRO directory, and the filename you provided is correct")
        exit(1)

def main():
    if len(sys.argv) == 1:
        print("[evolMAESTRO/build_tree] Usage: python build_tree.py /path/to/aligned/fasta")
        exit(1)
    call_megax()

if __name__ == "__main__":
    main()
