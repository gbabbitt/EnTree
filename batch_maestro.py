#/usr/bin/python3
infile = open("paths.ctl", "r")
infile_lines = infile.readlines()
for x in range(len(infile_lines)):
    infile_line = infile_lines[x]
    #print(infile_line)
    infile_line_array = str.split(infile_line)
    header = infile_line_array[0]
    value = infile_line_array[1]
    #print(header)
    #print(value)
    if(header == "maestro_path"):
        maestro_path= value
        print("my maestro path  is",maestro_path)
        
EVOLMAESTRO_PATH=maestro_path
MAESTRO_CMD_PATH=maestro_path+"MAESTRO_linux_x64/maestro"
MAESTRO_CONFIG_PATH=maestro_path+"MAESTRO_linux_x64/config.xml"

import os
import sys
import subprocess
cpuCount = os.cpu_count()
print("Number of CPUs in the system:", cpuCount) 
threads = str(cpuCount)

def make_attr(directory):
    subprocess.call("mkdir attribute_files", shell=True)
    file_paths = []
    for dirpath,_,filenames in os.walk(directory):
        for f in filenames:
            file_paths.append(os.path.abspath(os.path.join(dirpath, f)))

    for item in file_paths:
        out_line_list = []
        with open(item, "r") as fh:
            for line in fh:
                if line[0] != "#":
                    line = line.rstrip()
                    groups = line.split("\t")
                    residue = ":" + groups[0]
                    ddG = groups[2].lstrip()
                    out_line = "\t" + residue + "\t" + ddG
                    out_line_list.append(out_line)
        outfile_name = "attribute_files/attr_ddG_" + os.path.basename(item) + ".dat"
        outf = open(outfile_name, "w")
        outf.write("recipient: residues\n")
        outf.write("attribute: ddG\n")
        outf.write("\n")
        for outline in out_line_list:
            outf.write(outline + "\n")
        outf.close()

def pdb_list(directory):
    file_paths = []
    for dirpath,_,filenames in os.walk(directory):
        for f in filenames:
            file_paths.append(os.path.abspath(os.path.join(dirpath, f)))

    #pdbsfh = open("pdbpaths.txt", "w")
    #for item in file_paths:
    #    pdbsfh.write(item)
    #    pdbsfh.write("\n")
    #pdbsfh.close()

    #return(os.path.realpath(pdbsfh.name))
    return(file_paths)

def build_scancfgs(pdbpath, cfg_template): #can add chain specification and BU here later
    local_template = cfg_template.copy()
    pdbheader  = os.path.splitext(os.path.basename(pdbpath))[0]
    input_ln = "    <pdb model='' chain='*' bu='false'>" + pdbpath + "</pdb>\n"
    resultfile_ln = "        <resultfile>"+"maestro_mutresults/"+ pdbheader + "_mutresults.maestro</resultfile>\n"
    historyfile_ln = "        <historyfile>"+"maestro_history/"+ pdbheader + "_history.maestro</historyfile>\n"
    top_mutants_ln = "        <top_mutants>100</top_mutants>\n"
    singlepoint_ln = "        <singlepoint>"+"maestro_singlepoint/"+ pdbheader + "_singlepoint.maestro</singlepoint>\n"
    
    local_template.insert(3, input_ln)
    local_template.insert(5, singlepoint_ln)
    local_template.insert(5, top_mutants_ln)
    local_template.insert(5, historyfile_ln)
    local_template.insert(5, resultfile_ln)

    cfg_filename = "scancfg_" + pdbheader + ".xml"

    with open(cfg_filename, "w") as scancfg_fh:
        for line in local_template:
            scancfg_fh.write(line)

    return(cfg_filename)

def run_MAESTRO(cfg_file):
    cmd_template = MAESTRO_CMD_PATH + " " + MAESTRO_CONFIG_PATH + " --scanmut=" + cfg_file + " --nthread=" + threads
    subprocess.call(cmd_template, shell=True)

def main():
    if not os.path.exists(EVOLMAESTRO_PATH+"maestro_singlepoint"):
        os.mkdir(EVOLMAESTRO_PATH+"maestro_singlepoint")
    if not os.path.exists(EVOLMAESTRO_PATH+"maestro_history"):
        os.mkdir(EVOLMAESTRO_PATH+"maestro_history")
    if not os.path.exists(EVOLMAESTRO_PATH+"maestro_mutresults"):    
        os.mkdir(EVOLMAESTRO_PATH+"maestro_mutresults")
    pdblist_filepaths = ""
    cfg_template = []
    scancfg_filepaths = []
    try:
        filedir = sys.argv[1]
    except IndexError:
        print("Usage: python batch_maestro.py /directory/of/pdb/mutants")
        exit(1)

    try:
        pdblist_filepaths = pdb_list(sys.argv[1])
    except FileNotFoundError:
        print("PDB file list not found. Confirm the directory " + sys.argv[1] + " is populated")
        exit(1)

    with open("scancfg_TEMPLATE.xml") as templatefh:
        for line in templatefh:
            cfg_template.append(line)

    try:
        for item in pdblist_filepaths:
            scancfg_filepaths.append(build_scancfgs(item, cfg_template))
    except FileNotFoundError:
        print("scancfg_TEMPLATE.xml file not found in current directory")
        exit(1)
    
    for path in scancfg_filepaths:
        run_MAESTRO(path)

    make_attr(EVOLMAESTRO_PATH + "/maestro_singlepoint")
        
    print("MAESTRO scans are completed")

if __name__ == "__main__":
    main()
