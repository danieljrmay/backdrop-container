#!/usr/bin/env bash
#
# backdrop-container-create-image
#
# Author: Daniel J. R. May
#
# This script can be used to create a container image.
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
	echo 'backdrop-container create-image [OPTIONS] [IMAGE_RECIPE]>'
	echo
	echo 'Options:'
	echo -e "\t-d, --debug\tPrint loads of messages (useful for debugging)"
	echo -e "\t-h, --help\tPrint this help message"
	echo -e "\t-v, --verbose\tPrint messages when running"
	echo -e "\t-V, --version\tPrint version information"
	echo
	echo 'For more information see <https://github.com/danieljrmay/backdrop-container>'
}

# Process the command line arguments
debug 'Processing the command line flags'
_temp=$(getopt --options 'dhvV' --longoptions 'debug,help,verbose,version' --name 'backdrop-container create-image' -- "$@")
eval set -- "$_temp"
unset _temp

# Process the command line flags
while true; do
	case "$1" in
	'-d' | '--debug')
		debug '-d | --debug flag detected'
		_verbosity=$_verbosity_debug
		shift
		continue
		;;
	'-h' | '--help')
		debug '-h | --help flag detected'
		print_help
		exit $_exit_status_ok
		;;
	'-v' | '--verbose')
		debug '-v | --verbose flag detected'
		_verbosity=$_verbosity_verbose
		shift
		continue
		;;
	'-V' | '--version')
		debug '-V | --version flag detected'
		print_version
		exit $_exit_status_ok
		;;
	'--')
		shift
		break
		;;
	*)
		error 'Accessed code which should be inaccessible.'
		exit $_exit_status_inaccessible_code
		;;
	esac
done

# Process the next command line argument which is assumed to be an image recipe name
if [ "$_exec_environment" = 'src' ]; then
	image_recipe_path="./images/backdrop-container-create-image-$1.bash"

	if [ -r "$image_recipe_path" ]; then
		exec bash "$image_recipe_path"
	else
		error "Image recipe $image_recipe_path does not exist or is not readable"
		exit $_exit_status_file_not_found
	fi
else
	image_recipe_path="/usr/local/bin/backdrop-container-create-image-$1.bash"

	if [ -x "$image_recipe_path" ]; then
		exec "$image_recipe_path"
	else
		error "Image recipe $image_recipe_path does not exist or is not executable"
		exit $_exit_status_file_not_found
	fi
fi
