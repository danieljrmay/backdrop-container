# Backdrop Add-on Development MariaDB Image #

This directory contains the files used to create the
`backdrop-add-on-devel-mariadb-image`. This is an image based on the
latst version of `fedora` with `mariadb-server` installed and an empty
database created for `backdrop`.

Here’s a little explaination about what each file is for:

* `configure-backdrop-add-on-devel-mariadb.service` defines a
  `systemd` service which executes the
  `configure-backdrop-add-on-devel-mariadb.bash` script one-time
  only.
* `configure-backdrop-add-on-devel-mariadb.bash` is a script which
  creates an empty database for `backdrop`.
* `create-backdrop-add-on-devel-mariadb-image.bash` a script which
  creates the image using various `buildah` commands.

## Create the image ##

Create the MariaDB image with:

```shell_session
bash create-backdrop-add-on-devel-maraidb-image.bash 
```

## Run and expore an instance of the image ##

You can run and explore an instance of this image with:

```shell_session
podman run --detach --name my-mariadb localhost/backdrop-add-on-devel-maraidb
podman exec --tty --interactive my-mariadb /bin/bash
```

You can then check that mariadb is running:

```shell_session
[root@610df4c678e9 /]# systemctl status mariadb
● mariadb.service - MariaDB 10.5 database server
     Loaded: loaded (/usr/lib/systemd/system/mariadb.service; enabled; vendor preset: disabled)
     Active: active (running) since Wed 2022-03-02 13:10:34 UTC; 30s ago
       Docs: man:mariadbd(8)
             https://mariadb.com/kb/en/library/systemd/
    Process: 27 ExecStartPre=/usr/libexec/mariadb-check-socket (code=exited, status=0/SUCCESS)
    Process: 53 ExecStartPre=/usr/libexec/mariadb-prepare-db-dir mariadb.service (code=exited, status=0/SUCCESS)
    Process: 172 ExecStartPost=/usr/libexec/mariadb-check-upgrade (code=exited, status=0/SUCCESS)
   Main PID: 141 (mariadbd)
     Status: "Taking your SQL requests now..."
      Tasks: 31 (limit: 307)
     Memory: 75.6M
        CPU: 536ms
     CGroup: /system.slice/mariadb.service
             └─141 /usr/libexec/mariadbd --basedir=/usr

Mar 02 13:10:34 610df4c678e9 mariadb-prepare-db-dir[91]: See the MariaDB Knowledgebase at https://mariadb.com/kb or the
Mar 02 13:10:34 610df4c678e9 mariadb-prepare-db-dir[91]: MySQL manual for more instructions.
Mar 02 13:10:34 610df4c678e9 mariadb-prepare-db-dir[91]: Please report any problems at https://mariadb.org/jira
Mar 02 13:10:34 610df4c678e9 mariadb-prepare-db-dir[91]: The latest information about MariaDB is available at https://mariadb.org/.
Mar 02 13:10:34 610df4c678e9 mariadb-prepare-db-dir[91]: You can find additional information about the MySQL part at:
Mar 02 13:10:34 610df4c678e9 mariadb-prepare-db-dir[91]: https://dev.mysql.com
Mar 02 13:10:34 610df4c678e9 mariadb-prepare-db-dir[91]: Consider joining MariaDB's strong and vibrant community:
Mar 02 13:10:34 610df4c678e9 mariadb-prepare-db-dir[91]: https://mariadb.org/get-involved/
Mar 02 13:10:34 610df4c678e9 mariadbd[141]: 2022-03-02 13:10:34 0 [Note] /usr/libexec/mariadbd (mysqld 10.5.13-MariaDB) starting as process 141 ...
Mar 02 13:10:34 610df4c678e9 systemd[1]: Started MariaDB 10.5 database server.
```

You can check that our `configure-backdrop-add-on-devel-maraidb`
systemd service has run by checking the logs with:

```shell_session
[root@610df4c678e9 /]# journalctl --unit configure-backdrop-add-on-devel-maraidb
Mar 02 13:10:34 610df4c678e9 systemd[1]: Starting Configure MariaDB for Backdrop Add-On Development...
Mar 02 13:10:34 610df4c678e9 systemd[1]: configure-backdrop-add-on-devel-maraidb.service: Deactivated successfully.
Mar 02 13:10:34 610df4c678e9 systemd[1]: Finished Configure MariaDB for Backdrop Add-On Development.
```

You can check that a database has been created for backdrop with:

```shell_session
[root@610df4c678e9 /]# mariadb -uroot
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 4
Server version: 10.5.13-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> SHOW DATABASES;
+------------------------+
| Database               |
+------------------------+
| backdrop_database_name |
| information_schema     |
| mysql                  |
| performance_schema     |
+------------------------+
4 rows in set (0.002 sec)

MariaDB [(none)]> exit
```

Exit the container by entering `exit` at the command prompt so that
you are back on the *container host* environment. You can then stop and
remove your container with:

```shell_session
podman stop my-mariadb
podman rm my-mariadb
```
