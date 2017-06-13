#!/bin/bash
# License: The MIT License (MIT)
# Author Zuzzuc https://github.com/Zuzzuc


exitw(){
	# Exits and echos message.
	# Input is $1 and $2, where $1 is the exit code (0-256) and $2 is the message to display.
	echo "$2"
	exit $1
}

ExitStatus="0"

# Colors
lightblue='\033[1;34m'
nocolor='\033[0m'

# Default vars
config=""
dlbar="true"
cont="true"
sdlb="false"
color="true"


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
   					exitw "3" "Config file points to this script."
   				else
   					if [ "$(read -r tmpc 2>/dev/null < "$c" 2>/dev/null ;echo "$tmpc")" == '#Basi Config File' ];then
   						config="$c"
   					else
   						echo its .$tmpc.
   						exitw "3" "Config file missing first line mark"
   					fi
   				fi
   			else
   				exitw "3" "Config file does not end with cfg."
   			fi
   			;;
   		-nodlb|--no_download_bar)
   				dlbar="false"
   			;;
   		-sdlb|--small_download_bar)
   				sdlb="true"
   			;;
   		-nocont|--no_continue)
   			cont="false"
   			;;
   		-nocol|--no_color)
   			color="false"
   			;;
   		*)
   			exitw "9" "Unknown argument '$i'"
   			;;
		esac
	done
fi

if [ "$(caller 0)" != "" ];then
	LaunchMode="Inline"
else
	LaunchMode="Standalone"
fi


# Read config
if [ "$config" != "" ];then
	if [ -f "$config" ];then
		echo -e "\nReading config from $config\n"
		source "$config"
	else
		exitw "4" "Config file not found."
	fi
elif [ "$LaunchMode" == "Standalone" ];then
	if [ -f "${0%/*}/Basi.cfg" ];then
		echo -e "\nReading config from default file\n"
		source "${0%/*}/Basi.cfg"
	else
		exitw "8" "No config file found."
	fi
fi


# Auth vars
if [ "${#BasiPath[@]}" != "0" ] && [ "${#BasiLoc[@]}" != "0" ];then		
	if [ "${#BasiPath[@]}" == "${#BasiLoc[@]}" ];then
		if [ "${#BasiLoc[@]}" -lt "${#BasiFileAction[@]}" ];then
			exitw "7" "Too many FileActions"
		fi	
	else
		exitw "6" "File source/destination is not correctly formatted."
	fi
else
	exitw "5" "Critical variable missing. Aborting"
fi

# Transfer files
for ((i=0;i<=$((${#BasiPath[@]}-1));i++));do
	if [ "BasiPath[i]" != "" ];then
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
			exitw "2" "Unknown location to retrive file from. Encountered format was '${BasiPath[i]/\%*/}'"
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

if [ "$LaunchMode" == "Standalone" ];then
	exit $ExitStatus
elif [ "$LaunchMode" == "Inline"  ];then
	return $ExitStatus
fi