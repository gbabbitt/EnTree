swapaa GLN :2.a
swapaa THR :4.a
swapaa LYS :5.a
swapaa SER :9.a
swapaa GLN :10.a
swapaa LEU :11.a
select :14.a
delete selected
select :15.a
delete selected
swapaa ASP :16.a
swapaa ILE :17.a
swapaa GLY :21.a
swapaa ALA :24.a
swapaa PRO :26.a
swapaa GLU :27.a
swapaa LEU :28.a
swapaa ILE :29.a
swapaa THR :31.a
swapaa MET :32.a
swapaa PHE :33.a
swapaa HIS :34.a
swapaa THR :35.a
swapaa ASP :39.a
swapaa GLN :41.a
swapaa ILE :43.a
swapaa VAL :44.a
swapaa GLU :45.a
swapaa ASN :47.a
select :48.a
delete selected
select :49.a
delete selected
swapaa GLU :50.a
swapaa GLU :53.a
swapaa LEU :56.a
swapaa SER :60.a
swapaa ASN :61.a
swapaa LYS :62.a
swapaa LEU :63.a
swapaa LYS :66.a
swapaa SER :67.a
swapaa SER :68.a
swapaa GLN :69.a
swapaa VAL :70.a
swapaa GLN :72.a
swapaa SER :73.a
swapaa ARG :74.a
swapaa ILE :76.a
swapaa ASP :78.a
swapaa ILE :79.a
swapaa ASP :82.a
swapaa LYS :83.a
swapaa PHE :84.a
swapaa ASP :86.a
swapaa ASP :88.a
swapaa THR :90.a
swapaa ASP :92.a
swapaa ILE :93.a
swapaa MET :94.a
swapaa LYS :98.a
swapaa ILE :99.a
swapaa LEU :100.a
swapaa ASP :101.a
select :102.a
delete selected
swapaa ILE :103.a
swapaa LYS :104.a
swapaa ASP :107.a
swapaa TYR :108.a
swapaa LEU :110.a
swapaa HIS :112.a
swapaa LYS :113.a
swapaa ALA :114.a
swapaa LEU :115.a
swapaa THR :117.a
select :118.a
delete selected
swapaa GLU :119.a
swapaa LYS :120.a
swapaa LEU :121.a
swapaa GLU :122.a
swapaa TRP :124.a
swapaa LEU :125.a
swapaa CYS :126.a
swapaa GLU :127.a
swapaa LYS :128.a
swapaa LEU :129.a
select :130.a
delete selected
write 0 pdb_mutants_temp/1rex_temp1_chaina.pdb
close 0
