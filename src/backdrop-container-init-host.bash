#!/usr/bin/env bash
#
# backdrop-container-init-host
#
# Author: Daniel J. R. May
#
# This script should be run on the host which is running the
# containers. It configures SELinux so it contains so sudo-ed commands
# so you will need administrator access to run it.
#
# For more information (or to report issues) go to
# https://github.com/danieljrmay/backdrop-container

# Allow SELinux systems to allow systemd to manipulate its Cgroups
# configuration

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
	echo 'backdrop-container init-host [OPTIONS]'
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
_temp=$(getopt --options 'dhvV' --longoptions 'debug,help,verbose,version' --name 'backdrop-container init-host' -- "$@")
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

# Check if SELinux is available (enabled or disabled) on this host
if [ -x /usr/sbin/selinuxenabled ]; then
	verbose 'Host system is SELinux compatible'
else
	info 'Host system is not SELinux compatible, so there is nothing to do.'
	exit $_exit_status_ok
fi

# Check if SELinux is enabled
if selinuxenabled; then
	verbose 'SELinux is enabled'
else
	warn 'SELinux is disabled on the host system, so there is nothing to do.'
	exit $_exit_status_ok

fi

# Turn on SELinux boolean 'container_manage_cgroup' if required
if [ "$(getsebool container_manage_cgroup)" = 'container_manage_cgroup --> on' ]; then
	verbose 'SELinux boolean container_manage_cgroup is already on'
	exit $_exit_status_ok
else
	verbose 'SELinux boolean container_manage_cgroup is off, need to turn it on'
	message='The SELinux boolean container_manage_cgroup is currently off, and '
	message+='needs to be turned on by executing the command:\n\n'
	message+='\tsudo setsebool -P container_manage_cgroup true\n\n'
	message+='This script will attempt to execute this command now, so you may be asked '
	message+='for your administrator password.\nIf you understandably do not want to enter '
	message+='your adminstrator password into this script, simply press Ctrl+C\nto stop '
	message+='this script and enter the above command manually.'
	msg "$message"
	sudo setsebool -P container_manage_cgroup true
fi
