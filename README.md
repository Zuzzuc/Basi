# Basi
This readme will be updated soon, but in short this is a script that makes writing installers easier.

Basi is a script used to make installers easier. It can either be used as a standalone script or a an inline function. 

## Usage

At the very least, Basi requires two variables to be able to run. These can either be set with a config file or, if Basi is being called as a inline function, can be declared in the calling script. These variables are 'BasiPath' and 'BasiLoc'. For formatting, see "Config setup" below.

## Arguments
### Config file
#### -c or --config
#### Requires a parameter
#### This option is REQUIRED if the script is being called as a standalone script.(Unless the parent process exported the require variables)
<br>This option chooses what file to read configuration from.<br><br>
Example: `/Basi.sh -c="config.cfg"`
<br><br><br>

### Disable download bar
#### -nodlb or --no-download-bar
<br>This option disables the download bar when reteriving files from remote server.<br><br>
Example: `/Basi.sh -c="config.cfg" -nodlb`
<br><br><br>

### Small download bar
#### -sdlb or --small-download-bar
<br>This option replaces the default download bar with a smaller one.<br><br>
Example: `/Basi.sh -c="config.cfg" -sdlb`
<br><br><br>

### Disable color scheme
#### -nocol or --no-color
<br>Disables printing color encoded text.<br><br>
Example: `/Basi.sh -c="config.cfg" -nocol`
<br><br><br>


## Config setup
### Inline

### Config file


## Exit codes
0: Everything went well.<br>
1: Generic error(Caused by subprocess)<br>
2: Unknown location to retrieve file from. It must be either 'local' or 'remote'.<br>
3: Not valid config file<br>
4: Config file not found.<br>
5: BasiPath or BasiLoc is missing or empty. <br>
6: BasiPath and BasiLoc isnt same length.<br>
7: More FileActions than files.<br>
8: Attempted to read default config, but didn't find the file.<br>
9: Unknown argument supplied to script<br>
<br>
