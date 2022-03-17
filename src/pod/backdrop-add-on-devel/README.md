# Backdrop Add-On Develeopment Pod #

This directory contains files used to create a
`backdrop-add-on-devel-pod` pod.

Here’s is what each file in this directory is for:

* `backdrop-add-on-devel-pod.secrets` contains secret information
which is passed into the pod’s containers via the `--secret` option of
`podman run` when creating the backdrop and mariadb containers. It
contains things like database usernames and passwords.
* `create-backdrop-add-on-devel-pod.bash` creates a running pod.
* `destroy-backdrop-add-on-devel-pod.bash` destroys a running pod.
