#!/bin/bash
# create-backdrop-add-on-devel-pod.bash
#
# Author: Daniel J. R. May
#
# This script creates a pod made up of:
#
#  1. A mariadb container based off the backdrop-add-on-devel-maraidb
#  image. See the mariadb-image subdirectory for more information
#  about this image.
#
#  2. A backdrop container based off the
#  backdrop-add-on-devel-backdrop image. See the backdrop-image
#  subdirectory for more information about this image.
#
# For more information (or to report issues) go to
# https://github.com/danieljrmay/backdrop-pod

# Script constants
script_name=$(basename "${BASH_SOURCE[@]}")
declare -r script_name
declare -r mariadb_image='localhost/backdrop-add-on-devel-maraidb'
declare -r backdrop_image='localhost/backdrop-add-on-devel-backdrop'

# Environment variables and their default values.
: "${BACKDROP_POD:=backdrop-add-on-devel-pod}"
: "${BACKDROP_POD_PUBLISHED_PORT:=8080}"
: "${MARIADB_CONTAINER:=backdrop-add-one-devel-mariadb}"
: "${BACKDROP_CONTAINER:=backdrop-add-one-devel-backdrop}"

# Errors
declare -ir error_image_does_not_exist=1

# Announce that the script is running
echo "Running the $script_name script..."

# Check that the mariadb image already exists.
if (podman image exists $mariadb_image); then
	echo "The $mariadb_image exists so we can continue..."
else
	echo "Error: No $mariadb_image image exists."
	echo "You must create this image by running the create-backdrop-add-on-devel-maraidb-image.bash script."
	exit $error_image_does_not_exist
fi

# Check that the backdrop image already exists.
if (podman image exists $backdrop_image); then
	echo "The $backdrop_image exists so we can continue..."
else
	echo "Error: No $backdrop_image image exists."
	echo "You must create this image by running the create-backdrop-add-on-devel-backdrop-image.bash script."
	exit $error_image_does_not_exist
fi

# Create the pod
podman pod create \
	--name "$BACKDROP_POD" \
	--publish "${BACKDROP_POD_PUBLISHED_PORT}:80" \
	--network bridge

# Create the secrets which will be passed into the containers
podman secret create backdrop-pod-secrets backdrop-add-on-devel-pod.secrets

# Create the mariadb container
podman run \
	--pod "$BACKDROP_POD" \
	--name "$MARIADB_CONTAINER" \
	--secret source=backdrop-pod-secrets,type=mount,mode=400,target=configure-backdrop-add-on-devel-maraidb \
	--detach \
	$mariadb_image

# Create the backdrop container
podman run \
	--pod "$BACKDROP_POD" \
	--name "$BACKDROP_CONTAINER" \
	--secret source=backdrop-pod-secrets,type=mount,mode=400,target=configure-backdrop-add-on-devel-backdrop \
	--detach \
	$backdrop_image

# Announce finish with instructions to complete backdrop installation
# via browser
echo 'Finished. Please continue the backdrop installation by visiting http://localhost:8080/install.php'
