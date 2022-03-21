#!/usr/bin/env bash
# configure-container-host.bash
#
# Author: Daniel J. R. May
#
# This script should be run on the host which is running the
# containers. It does things like configure SELinux, so it contains so
# sudo-ed commands so you will need administrator access to run it.
#
# For more information (or to report issues) go to
# https://github.com/danieljrmay/backdrop-pod

# Allow SELinux systems to allow systemd to manipulate its Cgroups
# configuration
sudo setsebool -P container_manage_cgroup true
