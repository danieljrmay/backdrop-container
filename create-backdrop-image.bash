#!/bin/bash
# create-backdrop-image.bash
#
# Author: Daniel J. R. May
#
# This script creates a containerised image of the backdrop CMS.
#
# For more information (or to report issues) go to
# https://github.com/danieljrmay/backdrop-pod


# Environment variables and their default values.
: "${BACKDROP_VERSION:=1.21.2}"
: "${BACKDROP_IMAGE:=backdrop-fedora}"


# Error codes
declare -ir error_image_exists=1


# Announce that the script is running
echo "Running the create-backdrop-image.bash script..."


# Echo the environment variables values being used by this execution
# of the script
echo "Using the following environment variables:"
echo "BACKDROP_VERSION=$BACKDROP_VERSION"
echo "BACKDROP_IMAGE=$BACKDROP_IMAGE"


# If buildah already has an image called BACKDROP_IMAGE we inform the
# user that they will have to remove it before trying again
# TODO the command in the if outputs an error we want it silent
if (buildah images "localhost/$BACKDROP_IMAGE" > /dev/null 2>&1)
then
    echo "Error: an image called localhost/$BACKDROP_IMAGE already exists."
    echo "You must remove this image before running this script again."
    
    exit $error_image_exists
fi


# Download and unzip the specified release of backdrop
echo "Downloading and unzipping backdrop release version $BACKDROP_VERSION..."
curl \
    --location \
    --output backdrop.zip \
    "https://github.com/backdrop/backdrop/releases/download/$BACKDROP_VERSION/backdrop.zip" &&
    unzip backdrop.zip


# Create a new image based on the latest version of fedora
buildah from --name "$BACKDROP_IMAGE" registry.fedoraproject.org/fedora:latest


# Install RPMs and clean up
buildah run "$BACKDROP_IMAGE" -- dnf --assumeyes update
buildah run "$BACKDROP_IMAGE" -- dnf --assumeyes install php php-gd php-mysqlnd
buildah run "$BACKDROP_IMAGE" -- dnf --assumeyes clean all


# Copy the backdrop files 
buildah copy "$BACKDROP_IMAGE" backdrop /var/www/html
buildah copy "$BACKDROP_IMAGE" configure-backdrop.bash /usr/local/bin/configure-backdrop
buildah copy "$BACKDROP_IMAGE" configure-backdrop.service /etc/systemd/system/configure-backdrop.service


# Change files permissions TODO might want to upload a correct settings.php file to begin with
buildah run "$BACKDROP_IMAGE" -- chown apache:apache /var/www/html/files
buildah run "$BACKDROP_IMAGE" -- chown apache:apache /var/www/html/settings.php
buildah run "$BACKDROP_IMAGE" -- chmod a+x /usr/local/bin/configure-backdrop


# Enable the services we are going to want
buildah run "$BACKDROP_IMAGE" -- systemctl enable httpd.service
buildah run "$BACKDROP_IMAGE" -- systemctl enable php-fpm.service
buildah run "$BACKDROP_IMAGE" -- systemctl enable configure-backdrop.service


# Configure the environment variables
buildah config --env BACKDROP_DATABASE_NAME="BACKDROP_DATABASE_NAME" "$BACKDROP_IMAGE"
buildah config --env BACKDROP_DATABASE_USER="BACKDROP_DATABASE_USER" "$BACKDROP_IMAGE"
buildah config --env BACKDROP_DATABASE_PASSWORD="BACKDROP_DATABASE_PASSWORD" "$BACKDROP_IMAGE"


# Expose port 80
buildah config --port 80 "$BACKDROP_IMAGE"


# Run systemd init command to get everthing going
buildah config --cmd "/usr/sbin/init" "$BACKDROP_IMAGE"


# Create the image
echo "Commiting the image..."
buildah commit "$BACKDROP_IMAGE" "$BACKDROP_IMAGE"


# Tidy up by removing downloaed and extracted files
echo "Tidying up by removing downloaed and extracted files..."
rm -rf backdrop.zip backdrop 

echo "Done"
exit
