# Backdrop Add-on Development Backdrop Image #

## Todo ##

Add a section here explaining what the files in this directory are
for.

## Create the image ##

Create the Backdrop image with:

```Shell
bash create-backdrop-add-on-devel-backdrop-image.bash 
```

## Run and expore an instance of the image ##

You can run and explore an instance of this image with:

```Shell
podman run --detach --name my-backdrop localhost/backdrop-add-on-devel-backdrop
podman exec --tty --interactive my-backdrop /bin/bash
```

You can then check that `httpd` is running:

```
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

```
[root@e0eca71e8940 /]# journalctl --identifier=configure-backdrop-add-on-devel-backdrop
Mar 02 14:31:50 e0eca71e8940 configure-backdrop-add-on-devel-backdrop[30]: Starting script.
Mar 02 14:31:50 e0eca71e8940 configure-backdrop-add-on-devel-backdrop[34]: Created /var/lock/configure-backdrop-add-on-devel-backdrop.lock to prevent the re-running of this script.
Mar 02 14:31:50 e0eca71e8940 configure-backdrop-add-on-devel-backdrop[37]: Updated the database connection configuration in the settings.php file.
Mar 02 14:31:50 e0eca71e8940 configure-backdrop-add-on-devel-backdrop[40]: Updated the trusted host patterns in the settings.php file.
Mar 02 14:31:50 e0eca71e8940 configure-backdrop-add-on-devel-backdrop[42]: Updated the database charset in the settings.php file.
Mar 02 14:31:50 e0eca71e8940 configure-backdrop-add-on-devel-backdrop[43]: Ending script.
```

Exit the container with:

```Shell
[root@610df4c678e9 /]# exit 
```

You can then stop and remove your container with:

```Shell
podman stop my-backdrop
podman rm my-backdrop
```