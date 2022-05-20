#!/usr/bin/env bash
#
# Libaray functions and variables for use in the
# backdrop-container.bash script.
#

# Variables
declare -r _version='0.0.1, 21 March 2022'

_exec_environment=$(basename "$(pwd)")
readonly _exec_environment

# Exit codes
declare -ir _exit_status_ok=0
declare -ir _exit_status_utils_not_found=1
declare -ir _exit_status_inaccessible_code=2
declare -ir _exit_status_syntax_error=3
declare -ir _exit_status_file_not_found=4

# Font formating related variables for easy text decoration when
# echoing output to the console.

# Colors are represented by numbers in tput, we give these numbers
# variable names to make this script more readable.
declare -ir _font_black=0
declare -ir _font_red=1
declare -ir _font_green=2
declare -ir _font_yellow=3
declare -ir _font_blue=4
declare -ir _font_magenta=5
declare -ir _font_cyan=6
declare -ir _font_white=7

# Background colors
_font_bg_black=$(tput setab $_font_black)
readonly _font_bg_black
_font_bg_red=$(tput setab $_font_red)
readonly _font_bg_red
_font_bg_green=$(tput setab $_font_green)
readonly _font_bg_green
_font_bg_yellow=$(tput setab $_font_yellow)
readonly _font_bg_yellow
_font_bg_blue=$(tput setab $_font_blue)
readonly _font_bg_blue
_font_bg_magenta=$(tput setab $_font_magenta)
readonly _font_bg_magenta
_font_bg_cyan=$(tput setab $_font_cyan)
readonly _font_bg_cyan
_font_bg_white=$(tput setab $_font_white)
readonly _font_bg_white

# Foreground colors
_font_fg_black=$(tput setaf $_font_black)
readonly _font_fg_black
_font_fg_red=$(tput setaf $_font_red)
readonly _font_fg_red
_font_fg_green=$(tput setaf $_font_green)
readonly _font_fg_green
_font_fg_yellow=$(tput setaf $_font_yellow)
readonly _font_fg_yellow
_font_fg_blue=$(tput setaf $_font_blue)
readonly _font_fg_blue
_font_fg_magenta=$(tput setaf $_font_magenta)
readonly _font_fg_magenta
_font_fg_cyan=$(tput setaf $_font_cyan)
readonly _font_fg_cyan
_font_fg_white=$(tput setaf $_font_white)
readonly _font_fg_white

# Font styles
_font_bold=$(tput bold)
readonly _font_bold
_font_dim=$(tput dim)
readonly _font_dim
_font_start_underline=$(tput smul)
readonly _font_start_underline
_font_stop_underline=$(tput rmul)
readonly _font_stop_underline
_font_reverse=$(tput rev)
readonly _font_reverse
_font_start_standout=$(tput smso)
readonly _font_start_standout
_font_stop_standout=$(tput rmso)
readonly _font_stop_standout
_font_reset=$(tput sgr0)
readonly _font_reset

# Logging functions to ease use when
# echoing output to the console or redirecting output to a log
# file.

# Verbosity constants
declare -ir _verbosity_silent=0
declare -ir _verbosity_warning=1
declare -ir _verbosity_normal=2
declare -ir _verbosity_verbose=3
declare -ir _verbosity_debug=4

# The default verbosity level
_verbosity=$_verbosity_debug

function debug {
	if [ "$_verbosity" -ge $_verbosity_debug ]; then
		echo -e "[${_font_bold}${_font_fg_blue}DEBUG${_font_reset}] $1"
	fi
}

function verbose {
	if [ "$_verbosity" -ge $_verbosity_verbose ]; then
		echo -e "[${_font_bold}${_font_fg_cyan}VERBOSE${_font_reset}] $1"
	fi
}

function msg {
	if [ "$_verbosity" -ge $_verbosity_normal ]; then
		echo -e "$1"
	fi
}

function ok {
	if [ "$_verbosity" -ge $_verbosity_normal ]; then
		echo -e "[${_font_bold}${_font_fg_green}OK${_font_reset}] $1" >&2
	fi
}

function info {
	if [ "$_verbosity" -ge $_verbosity_normal ]; then
		echo -e "[${_font_bold}${_font_fg_magenta}INFO${_font_reset}] $1" >&2
	fi
}

function warn {
	if [ "$_verbosity" -ge $_verbosity_warning ]; then
		echo -e "[${_font_bold}${_font_fg_yellow}WARNING${_font_reset}] $1" >&2
	fi
}

function error {
	echo -e "[${_font_bold}${_font_fg_red}ERROR${_font_reset}] $1" >&2
}

# Print version to user this can be called by all command scripts with
# the [-V|--version] flag
print_version() {
	echo "backdrop-container version $_version"
}

list_image_recipes() {
	for f in $1; do
		if [[ $(basename "$f") =~ create-image-(.+)\.bash ]]; then
			echo "${BASH_REMATCH[1]}"
		fi
	done
}
