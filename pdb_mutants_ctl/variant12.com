swapaa ILE :2.a
swapaa TYR :3.a
swapaa ILE :11.a
swapaa ALA :15.a
swapaa LEU :17.a
swapaa ILE :29.a
swapaa MET :31.a
swapaa TYR :33.a
swapaa TYR :34.a
swapaa ILE :43.a
select :48.a
delete selected
swapaa GLY :50.a
swapaa ASN :67.a
swapaa ASN :72.a
swapaa LYS :74.a
swapaa VAL :76.a
swapaa MET :79.a
swapaa ASN :86.a
swapaa THR :90.a
swapaa ILE :93.a
swapaa ILE :94.a
swapaa LYS :98.a
swapaa ILE :99.a
swapaa GLU :102.a
swapaa MET :106.a
swapaa ASN :107.a
swapaa TYR :108.a
swapaa HIS :114.a
swapaa HIS :115.a
swapaa GLY :118.a
swapaa LEU :121.a
swapaa SER :122.a
swapaa TRP :124.a
swapaa ASP :129.a
write 0 pdb_mutants_temp/1rex_temp12_chaina.pdb
close 0
