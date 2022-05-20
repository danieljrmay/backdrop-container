#!/usr/bin/env bash
#
# backdrop-container
#
# Author: Daniel J. R. May
#
# For more information (or to report issues) go to
# https://github.com/danieljrmay/backdrop-container

# Source library of utility functions and variables
if [ -r lib/utils.lib.bash ]; then
	source lib/utils.lib.bash
	debug 'Sourced utils.lib.bash from development execution environment'
elif [ -r /usr/lib/backdrop-container/utils.lib.bash ]; then
	source /usr/lib/backdrop-container/utils.lib.bash
	debug 'Sourced utils.lib.bash'
else
	echo 'ERROR: unable to load utils.lib.bash'
	exit $_exit_status_utils_not_found
fi

print_help() {
	echo 'backdrop-container [OPTIONS] <COMMAND> [ARGS]'
	echo
	echo 'Options:'
	echo -e "\t-d, --debug\tPrint loads of messages (useful for debugging)"
	echo -e "\t-h, --help\tPrint this help message"
	echo -e "\t-v, --verbose\tPrint messages when running"
	echo -e "\t-V, --version\tPrint version information"
	echo
	echo 'Commands:'
	echo -e "\tcreate-image\t\tCreate a container image"
	echo -e "\tinit-host\t\tInitialize the container host machine"
	echo -e "\tlist-image-recipes\tList the available image recipes"
	echo
	echo 'Get command specific help with:'
	echo -e "\tbackdrop-container <COMMAND> -h"
	echo
	echo 'For more information see <https://github.com/danieljrmay/backdrop-container>'
}

# Process the command line arguments
while true; do
	case "$1" in
	'create-image')
		shift
		debug "create-image command detected with arguments: $*"
		if [ "$_exec_environment" = 'src' ]; then
			debug "Executing backdrop-container-create-image.bash in development execution environment"
			exec bash backdrop-container-create-image.bash "$*"
		else
			debug "Executing backdrop-container-create-image in production execution environment"
			exec backdrop-container-create-image "$*"
		fi
		;;
	'init-host')
		shift
		debug "init-host command detected with arguments: $*"
		if [ "$_exec_environment" = 'src' ]; then
			debug "Executing backdrop-container-init-host.bash in development execution environment"
			exec bash backdrop-container-init-host.bash "$*"
		else
			debug "Executing backdrop-container-init-host in production execution environment"
			exec backdrop-container-init-host "$*"
		fi
		;;
	'list-image-recipes')
		shift
		debug "list-image-recipes command detected with arguments: $*"
		if [ "$_exec_environment" = 'src' ]; then
			debug "Executing list-image-recipes() in development execution environment"
			list_image_recipes 'image/create-image-*.bash'
		else
			debug "Executing list-image-recipes()"
			list_image_recipes '/usr/local/bin/create-image-*.bash'
		fi
		exit $_exit_status_ok
		;;
	'-d' | '--debug')
		shift
		debug '-d | --debug option detected'
		_verbosity=$_verbosity_debug
		continue
		;;
	'-h' | '--help')
		shift
		debug '-h | --help option detected'
		print_help
		exit $_exit_status_ok
		;;
	'-v' | '--verbose')
		shift
		debug '-v | --verbose option detected'
		_verbosity=$_verbosity_verbose
		continue
		;;
	'-V' | '--version')
		shift
		debug '-V | --version option detected'
		print_version
		exit $_exit_status_ok
		;;
	'--')
		shift
		debug '-- option detected'
		continue
		;;
	'')
		error "Illegal invokation, please check your syntax:"
		break
		;;
	*)
		error "'$1' is not a recognised option or command, please check your syntax:"
		break
		;;
	esac
done

print_help
exit $_exit_status_syntax_error
