1. compile ftserver.c
$gcc -std=gnu99 -o ftserver ftserver.c

2. chmod ftclient.py
$chmod +x ftclient.py

3. run ftserver with a port number as the only argument
$./ftserver #####
(Example) $./ftserver 44670

4. run ftclient.py
* for a directory:
$./ftclient.py flip# ##### -l #####
(Example) $./ftclient.py flip1 44670 -l 44674
* for a file:
$./ftclient.py flip# ##### -g filename.txt #####
(Example) $./ftclient.py flip1 44670 -g Pride_and_Prejudice_by_Jane_Austen.txt 44674
