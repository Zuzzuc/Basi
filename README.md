# Basi
Basi is a script used to make writing installers simpler. It can either be used as a standalone script or as an inline function. All files to be proccessed should be located in their associated arrays. 

## Usage

At the very least, Basi requires two arrays to be declared in order to be able to run. These can either be set with a config file or, if Basi is being called as a inline function, can be declared in the calling script. These variables are 'BasiPath' and 'BasiLoc'. For formatting, see "Config setup" below.

## Arguments
### Config file
#### -c or --config
#### Requires a parameter
#### This option is REQUIRED if the script is being called as a standalone script.(Unless the parent process exported the required variables)
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

### No continue
#### -nocont or --no-continue
<br>This option prevents Basi to continue downloading incomplete files.<br><br>
Example: `/Basi.sh -c="config.cfg" -nocont`
<br><br><br>

### Disable color scheme
#### -nocol or --no-color
<br>Disables printing color encoded text.<br><br>
Example: `/Basi.sh -c="config.cfg" -nocol`
<br><br><br>


## Config setup
### General rules

Basi requires two arrays to be set. These are 'BasiPath' and 'BasiLoc', which respectivily decides what path to reterive the file from and where to store it locally. There is however one more array that can be utilized, which is named 'BasiFileAction', but more on that later.<br><br>
BasiPath requires some formatting before being submitted to Basi, while BasiLoc just needs to be a absolute filepath.<br>
The formating required on BasiPath is to tell Basi where it can find the files. The general syntax for BasiPath is 'mode%path', where mode is 'local' or 'remote' and path is a corresponding path where the file can be found. The length of both BasiPath and BasiLoc must be equal.
<br><br>
Example of BasiPath: `BasiPath[0]="local%/tmp/somefile.txt"`<br>
Example of BasiPath: `BasiPath[0]="remote%https://www.example.com/somefile.txt"`<br>
<br>
Example of BasiLoc: `BasiLoc[0]="/tmp/filedestination.txt"`<br>
<br>
<br>
The third array that can be utilized is named 'BasiFileAction'.<br>
This variable will allow you to post proccess the downloaded file. Once the transfer has finished, the content of BasiFileAction will be executed. A good example of where using this might be a good idea is when dealing with compressed archives. BasiFileAction length must not exceed BasiPath and BasiLoc's length <br><br> 
When BasiFileAction is being proccessed some variables that might be useful are set. These are 'BasiDir', which is the directory Basi is stored in(useful if the installer is located on a portable device), 'BasiActiveFile', which is the local path of the latest file downloaded (equals to `${BasiLoc[i]*%/}`) and 'BasiActiveFileDir' which is the directory of the file latest downloaded.

### Inline

When calling Basi as a inline function(preferrably by b64gz) make sure that both BasiPath and BasiLoc are declared and are corecctly formatted. 

### Config file

Basi config file has some rules. 

1. The first line must equal "#Basi Config File"
2. The filename must have the file extension .cfg
3. Config must consist of at the very least a correctly formatted BasiPath as well as a correctly formatted BasiLoc.

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
