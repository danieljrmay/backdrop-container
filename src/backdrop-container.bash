#!/usr/bin/env bash
#
# backdrop-container
#
# Author: Daniel J. R. May
#

# Variables
version='0.0.1, 21 March 2022'

# Exit codes
declare -ir exit_status_ok=0
declare -ir exit_status_utils_not_found=1
declare -ir exit_status_inaccessible_code=2
declare -ir exit_status_syntax_error=3

# Source library of utility functions and variables
if [ -r lib/utils.lib.bash ]; then
	source lib/utils.lib.bash
	debug 'Sourced utils.lib.bash'
else
	echo 'ERROR: unable to load utils.lib.bash'
	exit $exit_status_utils_not_found
fi

print_help() {
	echo 'backdrop-container [FLAGS] <SUBCOMMAND>'
	echo
	echo 'Options:'
	echo -e "\t-d, --debug\tPrint loads of messages (useful for debugging)"
	echo -e "\t-h, --help\tPrint this help message"
	echo -e "\t-v, --verbose\tPrint messages when running"
	echo -e "\t-V, --version\tPrint version information"
	echo
	echo 'Subcommands:'
	echo -e "\tinit-host\tInitialize the container host machine"
	echo
	echo 'For more information see <https://github.com/danieljrmay/backdrop-container>'
}

print_version() {
	echo "backdrop-container version $version"
}

exec_init_host() {
	debug 'In exec_init_host()'

	if [ -x /usr/sbin/selinuxenabled ]; then
		debug 'Host system is SELinux compatible'
	else
		info 'Host system is not SELinux compatible, so there is nothing to do.'
		return
	fi

	if selinuxenabled; then
		debug 'SELinux is enabled'
	else
		warn 'SELinux is disabled on the host system, so there is nothing to do.'
		return
	fi

	# sudo setsebool -P container_manage_cgroup true
	if [ "$(getsebool container_manage_cgroup)" = 'container_manage_cgroup --> on' ]; then
		debug 'container_manage_cgroup is already on'
	else
		debug 'container_manage_cgroup is off, need to turn it on'
		# TODO
	fi
}

# Process the command line arguments
debug 'Processing the command line flags'
_temp=$(getopt --options 'dhvV' --longoptions 'debug,help,verbose,version' --name 'backdrop-container' -- "$@")
eval set -- "$_temp"
unset _temp

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
		exit $exit_status_ok
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
		exit $exit_status_ok
		;;
	'--')
		shift
		break
		;;
	*)
		error 'Accessed code which should be inaccessible.'
		exit $exit_status_inaccessible_code
		;;
	esac
done

# Process the command line subcommand
debug 'Processing the command line subcommand'
for arg; do
	if [ "$arg" = 'init-host' ]; then
		debug 'init-host subcommand detected'
		exec_init_host
	elif [ "$arg" = 'create-image' ]; then
		debug 'create-image subcommand detected'
	else
		error "Unknown subcommand '$arg', check your syntax:"
		print_help
		exit $exit_status_syntax_error
	fi
done

# Exiting with success
exit $exit_status_ok
