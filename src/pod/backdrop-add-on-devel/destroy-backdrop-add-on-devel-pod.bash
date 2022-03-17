#!/bin/bash
# destroy-backdrop-add-on-devel-pod.bash
#
# Author: Daniel J. R. May
#
# For more information (or to report issues) go to
# https://github.com/danieljrmay/backdrop-pod

# Environment variables and their default values.
: "${BACKDROP_POD:=backdrop-add-on-devel-pod}"

podman pod stop $BACKDROP_POD
podman pod rm $BACKDROP_POD
podman secret rm backdrop-pod-secrets
