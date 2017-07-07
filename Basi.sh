#!/bin/bash
# License: The MIT License (MIT)
# Author Zuzzuc https://github.com/Zuzzuc

if [ "$(caller 0)" != "" ];then
	exit_mode="return"
else
	exit_mode="exit"
fi

# Colors
lightblue='\033[1;34m'
nocolor='\033[0m'

# Default vars
config=""
dlbar="true"
cont="true"
sdlb="false"
color="true"

catch_err(){
	# Input is $1 and optionally $2, where $1 is the error code description to display and $2 can be specified to override the default error message.
	if [ -z $2 ];then
		case "$1" in
    		1)
   				echo "Generic error encountered."
   				;;
   			2)
   				echo "Unknown location to retrieve file from. Encountered format was '$3'. It must be either 'local' or 'remote'."	
   				;;
   			3)
   				echo "Not valid config file."
   				;;
   			4)
   				echo "The config file '$3' was not found."
   				;;
   			5)
   				echo "BasiPath or BasiLoc is missing or empty."
   				;;
   			6)
   				echo "BasiPath and BasiLoc isnt same length."
   				;;
   			7)
   				echo "More FileActions than files."
   				;;
   			8)
   				echo "Attempted to read default config, but didn't find the file."
   				;;
   			9)
   				echo "Unknown argument supplied to script. Failing argument is '$3'"
   				;;
   		esac
   	else
   		echo "$2"
   	fi
   	error_code=$1
}

# Handle input
if [ "$*" != "" ];then	
	for i in "$@";do					
		case "$i" in		
		"$0")
    		continue
    		;;
		-c=*|--config=*)
   			c="${i#*=}" && c="${c/\\/}" && c="${c%${c##*[![:space:]]}}"
   			if [ "${c:${#c}-4}" == ".cfg" ];then
   				if [ "$c" == "${0/\\/}" ];then
   					catch_err "3" "Config file points to this script" && $exit_mode $error_code
   				else
   					if [ "$(read -r tmpc 2>/dev/null < "$c" 2>/dev/null ;echo "$tmpc")" == '#Basi Config File' ];then
   						config="$c"
   					else
   						catch_err "3" "Config file is missing first line mark" && $exit_mode $error_code
   					fi
   				fi
   			else
   				catch_err "3" "Config file does not end with .cfg" && $exit_mode $error_code
   			fi
   			;;
   		-nodlb|--no-download-bar)
   				dlbar="false"
   			;;
   		-sdlb|--small-download-bar)
   				sdlb="true"
   			;;
   		-nocont|--no-continue)
   			cont="false"
   			;;
   		-nocol|--no-color)
   			color="false"
   			;;
   		*)
   			catch_err "9" "" "$i" && $exit_mode $error_code
   			;;
		esac
	done
fi

# Read config
if [ "$config" != "" ];then
	if [ -f "$config" ];then
		echo -e "\nReading config from $config\n"
		source "$config"
	else
		catch_err "4" "" "$config" && $exit_mode $error_code
	fi
elif [ "$exit_mode" == "Standalone" ];then
	if [ -f "${0%/*}/Basi.cfg" ];then
		echo -e "\nReading config from default file\n"
		source "${0%/*}/Basi.cfg"
	else
		catch_err "8" && $exit_mode $error_code
	fi
fi

# Auth vars
if [ "${#BasiPath[@]}" != "0" ] && [ "${#BasiLoc[@]}" != "0" ];then		
	if [ "${#BasiPath[@]}" == "${#BasiLoc[@]}" ];then
		if [ "${#BasiLoc[@]}" -lt "${#BasiFileAction[@]}" ];then
			catch_err "7" && $exit_mode $error_code
		fi	
	else
		catch_err "6" && $exit_mode $error_code
	fi
else
	catch_err "5" && $exit_mode $error_code
fi

# Transfer files
for ((i=0;i<=$((${#BasiPath[@]}-1));i++));do
	if [ "$BasiPath[i]" != "" ];then
		if [ "${BasiPath[i]/\%*/}" == "local" ];then
			if [ "$color" == "true" ];then
				echo -e "Transferring ${lightblue}local${nocolor} file to ${BasiLoc[i]}"
			else
				echo "Transferring local file to ${BasiLoc[i]}"
			fi
			mkdir -p "${BasiLoc[i]%/*}"
			cp -Rf "${BasiPath[i]/*%/}" "${BasiLoc[i]}" 
		elif [ "${BasiPath[i]/\%*/}" == "remote" ];then
			if [ "$color" == "true" ];then
				echo -e "Transferring ${lightblue}remote${nocolor} file to ${BasiLoc[i]}"
			else
				echo "Transferring remote file to ${BasiLoc[i]}"
			fi
			mkdir -p "${BasiLoc[i]%/*}"
			if [ "$cont" == "true" ];then
				if [ "$dlbar" == "true" ];then
					if [ "$sdlb" == "true" ];then
						curl -o "${BasiLoc[i]}" -C - "${BasiPath[i]/*%/}" -#
					else
						curl -o "${BasiLoc[i]}" -C - "${BasiPath[i]/*%/}"
					fi
					echo -ne "\n"
				else
					curl -s -o "${BasiLoc[i]}" -C - "${BasiPath[i]/*%/}"
				fi
			else
				if [ "$dlbar" == "true" ];then
					if [ "$sdlb" == "true" ];then
						curl -o "${BasiLoc[i]}" "${BasiPath[i]/*%/}" -#
					else
						curl -o "${BasiLoc[i]}" "${BasiPath[i]/*%/}"
					fi
					echo -ne "\n"
				else
					curl -s -o "${BasiLoc[i]}" "${BasiPath[i]/*%/}"
				fi
			fi
		else
			catch_err "2" "" "${BasiPath[i]/\%*/}" && $exit_mode $error_code
		fi
		
		if [ "${BasiFileAction[i]}" != "" ];then
			echo "Performing operations on file ${BasiLoc[i]##*/}"
			BasiDir="${0%/*}"
			BasiActiveFile="${BasiLoc[i]/*%/}" 
			BasiActiveFileDir="${BasiActiveFile%/*}"
			eval "${BasiFileAction[i]}"
		fi
	else
		echo "Empty path found at slot $i. Skipping"
	fi
done