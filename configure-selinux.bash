#!/usr/bin/bash

# Allow SELinux systems to allow systemd to manipulate its Cgroups configuration
sudo setsebool -P container_manage_cgroup true
