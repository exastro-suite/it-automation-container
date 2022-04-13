# Using Exastro IT Automation's Container

This document uses the  explains the process of using the Exastro IT Automation container.
There are mainly 2 patterns of using the Container

  1. Directly using Docker and Podman container runtime
  1. Using Paas from services such as Kubernetes and Openshift


This document will focus on the first pattern, directly using a container runtime.
The second pattern will not be covered in this document


# 1. First, let us start it up.

The Exastro IT Automation image is [published on DockerHub](https://hub.docker.com/r/exastro/it-automation) and can be used by anyone.
This makes it easy for anyone to run Exastro IT Automation as long as they have a container runtime from services such as Docker and Podman.
The following steps of this guide assumes that the user has installed a container runtime.

With that, we can start by running the Exastro IT Automation container. Log in to the Linux machine where the container timer is installed and run the following command.
※If you are using podman commands, change the "docker" text with "podman". (Some options might be specified differently)  

```
# docker run \
    --name it-automation \
    --privileged \
    --add-host=exastro-it-automation:127.0.0.1 \
    -d \
    -p 8080:80 \
    -p 10443:443 \
    exastro/it-automation:1.9.0-en
```
    sucessfully started exastro/it-automatioExastro IT Automation.
Next, input  `http://localhost:8080/` into the your browser address bar and access Exastro IT Automation.
If the following screen is displayed, you have succesfully accessed Exastro ITA.
Note that if you are accessing from a machine different from the machine running the container, make sure to change `localhost` with the correct host name.

![Login screen](https://qiita-user-contents.imgix.net/https%3A%2F%2Fqiita-image-store.s3.ap-northeast-1.amazonaws.com%2F0%2F652376%2Ff25bcff6-d7f0-bd0f-d62b-a5c24f4a2795.png?ixlib=rb-4.0.0&auto=format&gif-q=60&q=75&w=1400&fit=max&s=403cb8689a5d7b58cb6503ba785b4944)


# 2. Production environment

In the previous step, we have shown you have to run the Exastro IT Automation container.
However, one might consider adding the following if they plan to use it for a production environment.

  * Data persistency
  * Serviced Systemd
  * TLS (SSL) support
  * Using Docker Compose

The following section will explain the following.

※ If you have finnished Step 1 and want to create a new container, note that you cannot use the same port number and the container name. If you want to to create a new container, either delete the existing container or specify a new port number and container name.
※ Change the text in brackets (【】) to fit your environment.
※ ITA running on a version earlier than 1.8.0 does not support the automatic file copy function when using bind mounts in the later mentioned "Simplyfied Mount points". 

# 3. Data persistency

In many cases, users will delete and recreate the container when they are updating.
Users needs to be carefull however, as the data inside the container will disappear together with the container when deleted. 
If they want to save the data when deleting the container, they will need to save it outside the container itself (making data persistent).

There are 2 ways of making data persistent
  
  * By using volumes
  * By using bind mounts
  
This section will explain both of the methods of adding data persistency.

## 3.1 Exastro IT Automation's data save location

For the Container version of Exastro IT Automation running on Ver 1.8.0 or later, the data is saved in the following 2 locations.

| path                     | Description                                                                                      |
| ------------------------ | ------------------------------------------------------------------------------------------------- |
| /exastro-file-volume     | Stores data files managed by Exastro. More specifically, created menus and uploaded files. |
| /exastro-database-volume | Stores MarioDB database files                                                              |

Users can add data persistency by using Bind mounts or mounting the volumes above.


## 3.2 Data persistency using Volumes

Docker has the ability to manage Volumes, which are directories outside the container. 
Volumes are independent from the Container and can be created and deleted at free will, meaning that users can store data they want to save.

In this section, we will show you how to add data persistency by using the volumes `exastro-file` and `exastro-database`.

First, we will run the following commands.

```
# docker volume create --name exastro-file
# docker volume create --name exastro-database
```

Next, specify `--volume` to the container run options and mount the volume to the container's file system.
The following commands runs the container with the `exastro-file` volume mounted to `/exastro-file-volume` and the `exastro-database` volume mounted to `/exastro-database-volume`.

```
# docker run \
    --name it-automation \
    --privileged \
    --add-host=exastro-it-automation:127.0.0.1 \
    --volume exastro-file:/exastro-file-volume \
    --volume exastro-database:/exastro-database-volume \
    -d \
    -p 8080:80 \
    -p 10443:443 \
    exastro/it-automation:1.9.0-en
```

If docker detects that the it is the first time using the newly created volume, it will automatically copy the files to the mounted volume.
Users can now use the volume normally.


## 3.3 Using bind mounts

Bind mounting is the method of directly mounting the host machine directory to the container.
In this section, we will use the same directories as before, `/exastro-file` and `/exastro-database`.

Before we start, run the commands below and create the directory we will bind mount on the host machine.

```
# sudo mkdir -m 777 /exastro-file
# sudo mkdir -m 777 /exastro-database
```

Next, specify `--volume` to the container run options and mount the host machine directory to the container file system.
The following commands runs the container with the host machine directory `exastro-file` mounted to `/exastro-file-volume` and the `exastro-database` directorty mounted to `/exastro-database-volume`.

```
# docker run \
    --name it-automation \
    --privileged \
    --add-host=exastro-it-automation:127.0.0.1 \
    --volume /exastro-file:/exastro-file-volume \
    --env EXASTRO_AUTO_FILE_VOLUME_INIT=true \
    --volume /exastro-database:/exastro-database-volume  \
    --env EXASTRO_AUTO_DATABASE_VOLUME_INIT=true \
    -d \
    -p 8080:80 \
    -p 10443:443 \
    exastro/it-automation:1.9.0-en
```

Note that the bind mount is different from a volume mount, as it does not include any automatic copy function from the source files.
However, the Exastro IT Automation container image comes with a function that that resets mounted directories if it is the first time it is being used.
This function can be used instead of the docker file copy function.

In order to use this function, configure the following 2 environment variable names and run the Exastro IT Automation container

| Environment variable name           | Default value  | Description                                                                                                         |
| ----------------------------------- | ------- | ------------------------------------------------------------------------------------------------------------ |
| `EXASTRO_AUTO_FILE_VOLUME_INIT`     | `false` | If `true`,`/exastro-file-volume` will be reset for the first bind mount. Will not be reset if `false`. 
| `EXASTRO_AUTO_DATABASE_VOLUME_INIT` | `false` | If `true`,`/exastro-database-volume` will be reset for the first bind mount. Will not be reset if `false`.|

In the container command above, we are setting the environment variables to `true`, which will automatically copy the files.

This function checks for a marker filed called `.initialized` inside the container directories to check if it is the first time they are used.
So make sure to not delete the `.initialized` file.


# 4. Serviced Systemd

This section guides the users through registering the container to the service and creating, starting and stopping containers with systemctl.

If you are creating, starting or stopping(deleting) containers with systemd
  - Create unit file  
    ※Container which systemd will be registered to must be created.  

```
    # vi /etc/systemd/system/【Service name】.service  
```

【Service name】.service description

```
[Unit]
 Description=【Service description】
 Requires=docker.service
 After=docker.service

[Service]
 Restart=always
 ExecStart=/usr/bin/docker run \
             --rm \
             --privileged \
             --add-host=exastro-it-automation:127.0.0.1 \
              -d \
              -p 8080:80 \
              -p 10443:443 \
              --name exastro01 \
              exastro/it-automation:1.9.0-en
 ExecStop=/usr/bin/docker stop exastro01
 RemainAfterExit=yes
[Install]
 WantedBy=default.target
```

- Load settings  
```
  # systemctl daemon-reload
```
     
- Create and run docker container
```
  # systemctl start 【Service name】.service
```

- stop(delete) docker  
  ※--the rm option is specified, meaning that the container will be deleted when stopped.
```
  # systemctl stop 【Service name】.service
```

If starting or stopping container with systemd
- Create unit file  
  ※Container which systemd will be registered to must be created.  

```
  # vi /etc/systemd/system/【Service name】.service
```

【Service name】.service description

```
[Unit]  
 Description=【Service description】
 Requires=docker.service  
 After=docker.service  

[Service]  
 Restart=always  
 ExecStart=/usr/bin/docker start exastro01  
 ExecStop=/usr/bin/docker stop exastro01  
 RemainAfterExit=yes  
[Install]  
 WantedBy=default.target  
```

- Load settings。  
```
  # systemctl daemon-reload
```
        
- Start docker container
```
  # systemctl start 【Service name】.service
```

- Stop docker container
```
  # systemctl stop 【Service name】.service
```

# 5. TLS (SSL) support

If you want to use an authentication certificate different from the ITA default certificate, make sure to store it as the following: /etc/pki/tls/certs/に(Certificate name).csr, (Certificate name).key. For more information, please refer to 【Appendix】ITA-Server_distrubuted_HA_configuration_installation_manual_8_(Web・AP).pdf→"Apache settings" 
※The following steps starts from loging in to the container.
※The manual below includes steps that covers creating a new self certificate, but you can also use a certificate sent from the Certificate authorities or no certificates if you are using http.

  - Login to container
    ※Change the exastro01(Container name) with your own container name.
```
    # docker exec -it exastro01 /bin/bash  
```

Manual  https://github.com/exastro-suite/it-automation-docs/raw/master/asset/Learn/ITA-Server_distrubuted_HA_Configuration_Installation_Manual.zip


# 6. Using Docker Compose

Docker Compose runs containers by loading the required option information from the `docker-compose.yml` file.
By using Docker Compose, users dont have to specify complicated run options everytime they want to start it.
The following is an example of the `docker-compose.yml`, which is used to assign volumes to the Exastro IT Automation container.

```
version: "3.8"
services:
  exastro:
    image: exastro/it-automation:1.9.0-en
    container_name: it-automation
    privileged: true
    extra_hosts:
      - "exastro-it-automation:127.0.0.1"
    ports:
      - "8080:80"
      - "10443:443"
    volumes:
      - exastro-database:/exastro-database-volume
      - exastro-file:/exastro-file-volume

volumes:
  exastro-database:
  exastro-file:
```

The `docker-compose.yml` example above mounts the `exastro-database` and `exastro-file` to the `/exastro-database-volume` and `/exastro-file-volume` mount points inside the container, resulting in data persitency.

In order to run the container with `docker-compose.yml`, we will need to run the following command

```
# docker-compose up -d
```


# Reference

  - Simplyfied Mount points  

When the container is built, the following symbolic links are created within the container, which moves the required files there.
To simplify external storage mount points, shared files are consolidated in /exastro-file-volume and database files in /exastro-database-volume.

| Link source | Link destination |
| :--- | :--- |
| /exastro /data_relay_storage/symphony | /exastro-file-volume/data_relay_storage/symphony |
| /exastro /data_relay_storage/conductor |  /exastro-file-volume/data_relay_storage/conductor |
| /exastro /data_relay_storage/ansible_driver |  /exastro-file-volume/data_relay_storage/ansible_driver |
| /exastro /ita_sessions | /exastro-file-volume/ita_sessions |
| /exastro /ita-root/temp | /exastro-file-volume/ita-root/temp |
| /exastro /ita-root/uploadfiles  | /exastro-file-volume/ita-root/uploadfiles |
| /exastro /ita-root/webroot/uploadfiles | /exastro-file-volume/ita-root/webroot/uploadfiles |
| /exastro /ita-root/webroot/menus/sheets | /exastro-file-volume/ita-root/webroot/menus/sheets |
| /exastro /ita-root/webroot/menus/users | /exastro-file-volume/ita-root/webroot/menus/users |
| /exastro /ita-root/webconfs/sheets | /exastro-file-volume/ita-root/webconfs/sheets |
| /exastro /ita-root/webconfs/users | /exastro-file-volume/ita-root/webconfs/users |
| /var/lib/mysql | /exastro-database-volume/mysql |
