#!/usr/bin/bash
#
# configure-backdrop-add-on-devel-maraidb
#
# Author: Daniel J. R. May
#
# This script creates and configures the backdrop database on
# mariadb. This script should be called only once by the
# configure-backdrop-add-on-devel-maraidb service. It creates a lock
# file to prevent repeated executions.
#
# For more information (or to report issues) go to
# https://github.com/danieljrmay/backdrop-pod


declare -r identifier='configure-backdrop-add-on-devel-maraidb'
declare -r lock_file_path='/var/lock/configure-backdrop-add-on-devel-maraidb.lock'

: "${BACKDROP_DATABASE_NAME:=backdrop_database_name}"
: "${BACKDROP_DATABASE_USER:=backdrop_database_user}"
: "${BACKDROP_DATABASE_PASSWORD:=backdrop_database_password}"


systemd-cat --identifier=$identifier echo 'Starting script.'

if [ -f "$lock_file_path" ]
then
    systemd-cat --identifier=$identifier --priority=warning \
                echo "Lock file $lock_file_path already exists, exiting."
    exit 1
else
    (
        touch $lock_file_path \
         && systemd-cat \
                --identifier=$identifier \
                echo "Created $lock_file_path to prevent the re-running of this script."
    ) || (
        systemd-cat \
            --identifier=$identifier \
            --priority=error \
            echo "Failed to create $lock_file_path so exiting." \
            && exit 2
    )
fi

mysql --user=root <<EOF
CREATE DATABASE ${BACKDROP_DATABASE_NAME};
GRANT ALL ON ${BACKDROP_DATABASE_NAME}.* TO '${BACKDROP_DATABASE_USER}'@'localhost' IDENTIFIED BY '${BACKDROP_DATABASE_PASSWORD}';
FLUSH   PRIVILEGES;
EOF

mysql_success=$?

if [ $mysql_success -eq 0 ]
then 
    systemd-cat \
        --identifier=$identifier \
        echo "Created and configured database $BACKDROP_DATABASE_NAME for $BACKDROP_DATABASE_USER@localhost."
else
    systemd-cat \
        --identifier=$identifier \
        --priority=error \
        echo "Failed to create the database $BACKDROP_DATABASE_NAME so exiting." 
    exit 3
fi

systemd-cat --identifier=$identifier echo 'Ending script.'
