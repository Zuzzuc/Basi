# Basi
This readme will be updated soon, but in short this is a script that makes writing installers easier.


## Exit codes
0: Everything went well.
1: Generic error(Caused by subprocess)
2: Unknown location to retrieve file from. It must be either 'local' or 'remote'.
3: Not valid config file
4: Config file not found.
5: BasiPath or BasiLoc is missing or empty. 
6: BasiPath and BasiLoc isnt same length.
7: More FileActions than files.
8: Attempted to read default config, but didn't find the file.
9: Unknown argument supplied to script
