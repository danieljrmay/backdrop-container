#!/bin/bash
# create-backdrop-add-on-devel-maraidb-image
#
# Author: Daniel J. R. May
#
# This script creates a container image of mariadb for use in a
# "backdrop add-on development" pod.
#
# For more information (or to report issues) go to
# https://github.com/danieljrmay/backdrop-pod

# Script constants
declare -r image='backdrop-add-on-devel-maraidb'
script_name=$(basename "${BASH_SOURCE[@]}")
declare -r script_name

# Error codes
declare -ir error_image_exists=1

# Announce that the script is running
echo "Running the $script_name script..."

# If buildah already has an image called image we inform the
# user that they will have to remove it before trying again
if (buildah images "localhost/$image" >/dev/null 2>&1); then
	echo "Error: an image called localhost/$image already exists."
	echo "You must remove this image before running this script again."

	exit $error_image_exists
fi

# Create a new image based on the latest version of fedora
buildah from --name "$image" registry.fedoraproject.org/fedora:latest

# Install RPMs and clean up
buildah run "$image" -- dnf --assumeyes update
buildah run "$image" -- dnf --assumeyes install mariadb-server
buildah run "$image" -- dnf --assumeyes clean all

# Copy the backdrop files
buildah copy "$image" configure-backdrop-add-on-devel-maraidb.bash /usr/local/bin/configure-backdrop-add-on-devel-maraidb
buildah copy "$image" configure-backdrop-add-on-devel-maraidb.service /etc/systemd/system/configure-backdrop-add-on-devel-maraidb.service

# Change files permissions
buildah run "$image" -- chmod a+x /usr/local/bin/configure-backdrop-add-on-devel-maraidb

# Enable the services we are going to want
buildah run "$image" -- systemctl enable mariadb.service
buildah run "$image" -- systemctl enable configure-backdrop-add-on-devel-maraidb.service

# Configure the environment variables
buildah config --env BACKDROP_DATABASE_NAME="backdrop_database_name" "$image"
buildah config --env BACKDROP_DATABASE_USER="backdrop_database_user" "$image"
buildah config --env BACKDROP_DATABASE_PASSWORD="backdrop_database_password" "$image"

# Run systemd init command to get everthing going
buildah config --cmd "/usr/sbin/init" "$image"

# Create the image
echo "Commiting the image..."
buildah commit "$image" "$image"

echo "Done"
exit
