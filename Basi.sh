#!/bin/bash
# License: The MIT License (MIT)
# Author Zuzzuc https://github.com/Zuzzuc


### Error codes
#
# 2: Unknown location to retrieve file from. It must be either local or remote.
# 3: Not valid config file
# 5: BasiPath or BasiLoc is missing or empty. 
# 6: BasiPath and BasiLoc isnt same length.
# 7: More FileActions than files.
# 8: Default config file not found.
#


## TODO
#
# Add input handler. 
#
# Add option too show progress when downloading.
#
# Add option to specify path to Config File. (Should it be required to end with .cfg? i think yes, but not thought much)
# Gör om så att filen är .cfg istället(dvs def=Basi.cfg)
#
# Choose default show/hide progress bar download
#
# Maybe add some sort of log, so we does not need to show all curl output, and instead show a cleaner window.
#
##


exitw(){
	# Exits and prints message.
	# Input is $1 and $2, where $1 is the exit code (0-256) and $2 is the message to display.
	echo "$2"
	exit $1
}

ExitStatus="0"


### Handle Input


## What vars should we set?
# 
# We should set override of default cfg file.
#
# We should set option to display/hide (decide what should be default) progress bar when downloading files.
#
#
#
#
#

# Default vars

config=""


if [ "$1" != "" ];then
	# Set input vars.
	
	for i in "$@";do
		# Loop thu all inout, and then do a case? or many if.
		
		# Do we need to shift here? 
		# I think no. I walks up by default. Just quit/exit.
		
		# Case is 2x as fast as if... so... well... 
		# Use case. U need to fix minify tho.
			
		case "$i" in
			# Check args and set vars
		
			"$0")
			# Should we use continue or ':'?
			:
    		# continue
    		;;
    		-c=*|--config=*)
    		# Below we do the equivalent of 'config=echo "${i#*=}" | xargs'.
    		# The reason we does it with parameter expansion is that it's roughly 100 times faster than calling xargs. 
   			config="${i#*=}" && config="${config/\\/}" && config="${config/* $/}"
   			# We need to do this because sadly parameter extension does not support nesting. (eg, ${string:#string-4})
   			config_length="${#config}"
   			if [ "${config:config_length-4}" == ".cfg" ];then
   				if [ "$config" == "$0" ];then
   					exitw "3" "Config file points to this script."
   				else
   					if [ firstlineISTHERIGHTONE ];then
   						# Then go
   						:
   					fi
   				fi
   			else
   				exitw "3" "Config file does not end with cfg."
   			fi
		easc
	done


else
	# SET STD VARS
	# Shall we set it before, so we does not need to set it twice?

fi

###



if [ "$(caller 0)" != "" ];then
	LaunchMode="Inline"
else
	LaunchMode="Standalone"
fi



if [  ];then

	#if [ -f "${0%/*}/Basi.cfg" ];then
	#		echo "Will source default config file."
	#		source "${0%/*}/Basi.cfg"
	#	else
	#		exitw "8" "No config file found."
	#	fi
	#fi

fi




# Auth vars
if [ "${#BasiPath[@]}" != "0" ] && [ "${#BasiLoc[@]}" != "0" ];then		
	if [ "${#BasiPath[@]}" == "${#BasiLoc[@]}" ];then
		if [ ${#BasiLoc[@]} -lt ${#BasiFileAction[@]} ];then
			exitw "7" "Too many FileActions"
		fi	
	else
		exitw "6" "File source/destination is not correctly formatted."
	fi
else
	exitw "5" "Critical variable missing. Aborting"
fi


for ((i=0;i<=$((${#BasiPath[@]}-1));i++));do
	if [ "BasiPath[i]" != "" ];then
		if [ "${BasiPath[i]/\%*/}" == "local" ];then
			echo "Transferring local file ${BasiLoc[i]%/*}"
			mkdir -p "${BasiLoc[i]%/*}"
			cp -Rf "${BasiPath[i]/*%/}" "${BasiLoc[i]}" 
		elif [ "${BasiPath[i]/\%*/}" == "remote" ];then
			echo "Transferring remote file ${BasiLoc[i]%/*}"
			mkdir -p "${BasiLoc[i]%/*}"
			curl -s -o "${BasiLoc[i]}" -C - "${BasiPath[i]/*%/}"
		else
			exitw "2" "Unknown location to retrive file from. Encountered format was '${BasiPath[i]/\%*/}'"
		fi
		
		if [ "${BasiFileAction[i]}" != "" ];then
			echo "Performing operations on file ${BasiLoc[i]%/*}"
			# Note this var. It can be useful for FileAction
			BasiActiveFile="${BasiPath[i]/*%/}" 
			eval "${BasiFileAction[i]}"
		fi
	else
		echo "Empty path found at slot $i. Skipping"
	fi
done

if [ "$LaunchMode" == "Standalone" ];then
	exit $ExitStatus
elif [ "$LaunchMode" == "Inline"  ];then
	return $ExitStatus
fi