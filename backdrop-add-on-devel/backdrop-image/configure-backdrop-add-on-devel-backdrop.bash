#!/usr/bin/bash
#
# configure-backdrop-add-on-devel-backdrop
#
# Author: Daniel J. R. May
#
# This script configures the backdrop installation for add-on
# development by modifying the settings.php file. This script should
# be called only once by the configure-backdrop-add-on-devel-backdrop
# service. It creates a lock file to prevent repeated executions.
#
# For more information (or to report issues) go to
# https://github.com/danieljrmay/backdrop-pod

declare -r identifier='configure-backdrop-add-on-devel-backdrop'
declare -r lock_file_path='/var/lock/configure-backdrop-add-on-devel-backdrop.lock'
declare -r settings_path='/var/www/html/settings.php'

: "${BACKDROP_DATABASE_NAME:=backdrop_database_name}"
: "${BACKDROP_DATABASE_USER:=backdrop_database_user}"
: "${BACKDROP_DATABASE_PASSWORD:=backdrop_database_password}"

systemd-cat --identifier=$identifier echo 'Starting script.'

if [ -f "$lock_file_path" ]; then
	systemd-cat --identifier=$identifier --priority=warning \
		echo "Lock file $lock_file_path already exists, exiting."
	exit 1
else
	(
		touch $lock_file_path &&
			systemd-cat \
				--identifier=$identifier \
				echo "Created $lock_file_path to prevent the re-running of this script."
	) || (
		systemd-cat \
			--identifier=$identifier \
			--priority=error \
			echo "Failed to create $lock_file_path so exiting." &&
			exit 1
	)
fi

# Database configuration
match_text='mysql://user:pass@localhost/database_name'
replacement_text="mysql://$BACKDROP_DATABASE_USER:$BACKDROP_DATABASE_PASSWORD@localhost/$BACKDROP_DATABASE_NAME"

if sed -i "s#${match_text}#${replacement_text}#g" $settings_path; then
	systemd-cat \
		--identifier=$identifier \
		echo "Updated the database connection configuration in the settings.php file."
else
	systemd-cat \
		--identifier=$identifier \
		--priority=error \
		echo "Failed to update the database connection configuration in the the settings.php file."
	exit 2
fi

# Trusted host patterns
# shellcheck disable=SC2016
trusted_host_php_code='$settings'
trusted_host_php_code+="['trusted_host_patterns'] = "
trusted_host_php_code+="array('^localhost:8080\$');"

if (echo "$trusted_host_php_code" >>/var/www/html/settings.php); then
	systemd-cat \
		--identifier=$identifier \
		echo "Updated the trusted host patterns in the settings.php file."
else
	systemd-cat \
		--identifier=$identifier \
		--priority=error \
		echo "Failed to update the trusted host patterns in the settings.php file."
	exit 3
fi

# Database Charset
# shellcheck disable=SC2016
database_charset_php_code='$database_charset'
database_charset_php_code+="'utf8mb4';"

if (echo "$database_charset_php_code" >>/var/www/html/settings.php); then
	systemd-cat \
		--identifier=$identifier \
		echo "Updated the database charset in the settings.php file."
else
	systemd-cat \
		--identifier=$identifier \
		--priority=error \
		echo "Failed to update the database charset in the settings.php file."
	exit 3
fi

systemd-cat --identifier=$identifier echo 'Ending script.'
