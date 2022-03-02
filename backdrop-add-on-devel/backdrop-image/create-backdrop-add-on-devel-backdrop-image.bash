#!/bin/bash
# create-backdrop-add-on-devel-backdrop-image
#
# Author: Daniel J. R. May
#
# This script creates a container image of backdrop & httpd for use in
# a "backdrop add-on development" pod.
#
# For more information (or to report issues) go to
# https://github.com/danieljrmay/backdrop-pod

# Script constants
declare -r image='backdrop-add-on-devel-backdrop'
script_name=$(basename "${BASH_SOURCE[@]}")
declare -r script_name

# Environment variables and their default values.
: "${BACKDROP_VERSION:=1.21.2}"

# Error codes
declare -ir error_image_exists=1
declare -ir error_failed_to_get_backdrop_release=2

# Announce that the script is running
echo "Running the $script_name script..."

# Echo the environment variables values being used by this execution
# of the script
echo "Using the following environment variables:"
echo "BACKDROP_VERSION=$BACKDROP_VERSION"

# If buildah already has an image called BACKDROP_IMAGE we inform the
# user that they will have to remove it before trying again
if (buildah images "localhost/$image" >/dev/null 2>&1); then
	echo "Error: an image called localhost/$image already exists."
	echo "You must remove this image before running this script again."

	exit $error_image_exists
fi

# Download and unzip the specified release of backdrop
echo "Downloading and unzipping backdrop release version $BACKDROP_VERSION..."
(
	curl \
		--location \
		--output backdrop.zip \
		"https://github.com/backdrop/backdrop/releases/download/$BACKDROP_VERSION/backdrop.zip" &&
		unzip backdrop.zip
) || (
	echo "Error: Failed to download the backdrop release $BACKDROP_VERSION or unzip it." &&
		exit $error_failed_to_get_backdrop_release
)

# Create a new image based on the latest version of fedora
buildah from --name "$image" registry.fedoraproject.org/fedora:latest

# Install RPMs and clean up
buildah run "$image" -- dnf --assumeyes update
buildah run "$image" -- dnf --assumeyes install php php-gd php-mysqlnd
buildah run "$image" -- dnf --assumeyes clean all

# Copy the backdrop files
buildah copy "$image" backdrop /var/www/html
buildah copy "$image" backdrop-add-on-devel.conf /etc/httpd/conf.d/backdrop-add-on-devel.conf
buildah copy "$image" configure-backdrop-add-on-devel-backdrop.bash /usr/local/bin/configure-backdrop-add-on-devel-backdrop
buildah copy "$image" configure-backdrop-add-on-devel-backdrop.service /etc/systemd/system/configure-backdrop-add-on-devel-backdrop.service

# Change files permissions
buildah run "$image" -- chown apache:apache /var/www/html/files
buildah run "$image" -- chown apache:apache /var/www/html/settings.php
buildah run "$image" -- chmod a+x /usr/local/bin/configure-backdrop-add-on-devel-backdrop

# Enable the services we are going to want
buildah run "$image" -- systemctl enable httpd.service
buildah run "$image" -- systemctl enable php-fpm.service
buildah run "$image" -- systemctl enable configure-backdrop-add-on-devel-backdrop.service

# Configure the environment variables
buildah config --env BACKDROP_DATABASE_NAME="BACKDROP_DATABASE_NAME" "$image"
buildah config --env BACKDROP_DATABASE_USER="BACKDROP_DATABASE_USER" "$image"
buildah config --env BACKDROP_DATABASE_PASSWORD="BACKDROP_DATABASE_PASSWORD" "$image"

# Expose port 80
buildah config --port 80 "$image"

# Run systemd init command to get everthing going
buildah config --cmd "/usr/sbin/init" "$image"

# Create the image
echo "Commiting the image..."
buildah commit "$image" "$image"

# Tidy up by removing downloaed and extracted files
echo "Tidying up by removing downloaed and extracted files..."
rm -rf backdrop.zip backdrop

echo "Done"
exit
