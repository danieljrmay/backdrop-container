#!/usr/bin/env bash
#
# backdrop-container
#
# Author: Daniel J. R. May
#

temp=$(getopt --options 'hvV' --longoptions 'help,verbose,version' --name 'backdrop-container' -- "$@")

eval set -- "$temp"
unset temp

while true; do
	case "$1" in
	'-h' | '--help')
		echo 'HELP'
		shift
		continue
		;;
	'-v' | '--verbose')
		echo 'VERBOSE'
		shift
		continue
		;;
	'-V' | '--version')
		echo 'VERSION'
		shift
		continue
		;;
	'--')
		shift
		break
		;;
	*)
		echo 'INACCESSIBLE'
		exit 1
		;;
	esac
done

echo "Remaining arguments:"
for arg; do
	echo "$arg"
done
