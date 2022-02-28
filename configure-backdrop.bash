#!/usr/bin/bash

echo "configure-backdrop has started..." > /var/www/html/configure-backdrop.txt

: "${BACKDROP_DATABASE_USER:=backdrop-db-user}"
: "${BACKDROP_DATABASE_PASSWORD:=backdrop-db-pwd}"
: "${BACKDROP_DATABASE_NAME:=backdrop-db-name}"

# Database string we want to replace
match_text='mysql://user:pass@localhost/database_name'

# Database string replacement
replacement_text="mysql://$BACKDROP_DATABASE_USER:$BACKDROP_DATABASE_PASSWORD@localhost/$BACKDROP_DATABASE_NAME"

sed -i "s#${match_text}#${replacement_text}#g" /var/www/html/settings.php

echo "configure-backdrop has finished." >> /var/www/html/configure-backdrop.txt

