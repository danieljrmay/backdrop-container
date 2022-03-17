# Backdrop Add-on Development Backdrop Image #

This directory contains the files used to create the
`backdrop-add-on-devel-backdrop-image`. This is an image based on the
latst version of `fedora` with `httpd`, `php` and what *should be* the
latest release of backdrop installed.

Here’s a little explaination about what each file is for:

* `backdrop-add-on-devel.conf` is the apache configuration file for
  the image.
* `configure-backdrop-add-on-devel-backdrop.service` defines a
  `systemd` service which executes the
  `configure-backdrop-add-on-devel-backdrop.bash` script one-time
  only.
* `configure-backdrop-add-on-devel-backdrop.bash` is a script which
  configures the backdrop installation by modifying `settings.php`.
* `create-backdrop-add-on-devel-backdrop-image.bash` a script which
  creates the image using various `buildah` commands.

## Create the image ##

Create the Backdrop image with:

```shell_session
bash create-backdrop-add-on-devel-backdrop-image.bash 
```

## Run and expore an instance of the image ##

You can run and explore an instance of this image with:

```shell_session
podman run --detach --name my-backdrop localhost/backdrop-add-on-devel-backdrop
podman exec --tty --interactive my-backdrop /bin/bash
```

You can then check that `httpd` is running:

```shell_session
[root@e0eca71e8940 /]# systemctl status httpd
● httpd.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disabled)
    Drop-In: /usr/lib/systemd/system/httpd.service.d
             └─php-fpm.conf
     Active: active (running) since Wed 2022-03-02 14:31:50 UTC; 16s ago
       Docs: man:httpd.service(8)
   Main PID: 49 (httpd)
     Status: "Total requests: 0; Idle/Busy workers 100/0;Requests/sec: 0; Bytes served/sec:   0 B/sec"
      Tasks: 177 (limit: 307)
     Memory: 13.6M
        CPU: 79ms
     CGroup: /system.slice/httpd.service
             ├─49 /usr/sbin/httpd -DFOREGROUND
             ├─50 /usr/sbin/httpd -DFOREGROUND
             ├─51 /usr/sbin/httpd -DFOREGROUND
             ├─52 /usr/sbin/httpd -DFOREGROUND
             └─54 /usr/sbin/httpd -DFOREGROUND

Mar 02 14:31:50 e0eca71e8940 systemd[1]: Starting The Apache HTTP Server...
Mar 02 14:31:50 e0eca71e8940 httpd[49]: AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 10.0.2.100. Set the 'ServerName' directive globally to suppress this message
Mar 02 14:31:50 e0eca71e8940 httpd[49]: Server configured, listening on: port 80
Mar 02 14:31:50 e0eca71e8940 systemd[1]: Started The Apache HTTP Server.
```

You can check that our `configure-backdrop-add-on-devel-backdrop`
systemd service has run by checking the logs with:

```shell_session
[root@e0eca71e8940 /]# journalctl --identifier=configure-backdrop-add-on-devel-backdrop
Mar 02 14:31:50 e0eca71e8940 configure-backdrop-add-on-devel-backdrop[30]: Starting script.
Mar 02 14:31:50 e0eca71e8940 configure-backdrop-add-on-devel-backdrop[34]: Created /var/lock/configure-backdrop-add-on-devel-backdrop.lock to prevent the re-running of this script.
Mar 02 14:31:50 e0eca71e8940 configure-backdrop-add-on-devel-backdrop[37]: Updated the database connection configuration in the settings.php file.
Mar 02 14:31:50 e0eca71e8940 configure-backdrop-add-on-devel-backdrop[40]: Updated the trusted host patterns in the settings.php file.
Mar 02 14:31:50 e0eca71e8940 configure-backdrop-add-on-devel-backdrop[42]: Updated the database charset in the settings.php file.
Mar 02 14:31:50 e0eca71e8940 configure-backdrop-add-on-devel-backdrop[43]: Ending script.
```

Exit the container by entering `exit` at the command prompt so that
you are back on the *container host* environment. You can then stop and
remove your container with:

```shell_session
podman stop my-backdrop
podman rm my-backdrop
```
