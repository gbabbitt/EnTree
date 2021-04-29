#EnTree

EnTree is a GUI enabled script to examine evolutionary changes in protein stability. It is tested on UCSF Chimera 1.14 (https://www.cgl.ucsf.edu/chimera/) installed Linux Mint 19.3. It also requires gedit, python kivy, perl-tk and pdb4amber (from AmberTools 18  https://ambermd.org/) or directly from GitHub (https://github.com/Amber-MD/pdb4amber) pdb4amber is only needed if an alignment file is used as the source of the PDB variants. 
![image](/maestroGUI.png)

To run:
python ENTREE.py

To install scripting dependencies:
sudo apt-get install gedit
sudo apt-get install perl-tk
sudo apt-get install python-tk
sudo apt-get install python-kivy
sudo cpan App::cpanminus
sudo apt install cpanminus
sudo cpanm Statistics::Descriptive

To install pdb4amber from AmberTools:
conda install ambertools -c conda-forge

To get Amber MD and AmberTools software
https://ambermd.org/

To get OpenMM MD software
http://openmm.org/

To get MegaX
https://www.megasoftware.net/

To install pdb4amber from GitHub:
pip install git+https://github.com/amber-md/pdb4amber

To get UCSF Chimera
https://www.cgl.ucsf.edu/chimera/

To get UCSF ChimeraX:
https://www.rbvi.ucsf.edu/chimerax/

