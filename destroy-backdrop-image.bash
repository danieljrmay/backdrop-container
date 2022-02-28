#!/usr/bin/bash

podman pod stop backdrop-pod
podman pod rm backdrop-pod
buildah rm backdrop-fedora
buildah rmi localhost/backdrop-fedora
