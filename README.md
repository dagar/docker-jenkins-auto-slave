## Jenkins auto slave

A docker image of Jenkins `JNLP` based agent. This image can self-register to Jenkins master, it will also unregister from the master when container exits. Another cool feature is that this image doesn't have `agent.jar` pre installed, instead it downloads it from Jenkins master when the container starts. This approach will help to avoid versioning problems that might happen between `master` and `slave`.

***

**Environment variables**

most used variables:

- `JENKINS_AUTH` jenkins server username and either password or API token (in `user:secet` format)
- `JENKINS_URL` jenkins master url (example `http://localhost:8080`)
- `JENKINS_SLAVE_NAME` the name which will be used when registering (default is `$HOSTNAME`)
- `JENKINS_SLAVE_LABELS` 

less used and can keep the defaults

- `DOCKER_GROUP` the docker group name, should be same as the docker's host group (defaults to `docker`)
- `DOCKER_SOCKET` the docker socket location (default is `/var/run/docker.sock`)
- `JAVA_OPTS` pass java options to the `slave.jar` process (default is not set)

***

**Required permissions**

The image should be used in trusted environment, even so the permissions for the user that will be used to register the slaves should be restricted.

> **DO NOT USE ADMIN USER**

Therefore, in order to be able to self register to the master, a user with relevant permissions must be created.

The required permissions are:

- `Overall/Read`
- `Agent/Connect`
- `Agent/Create`
- `Agent/Delete`

***

**Running**

when running without any env variables:

```sh
$ docker run --rm simenduev/jenkins-auto-slave
please set both JENKINS_URL and JENKINS_AUTH env. variables
example:
JENKINS_AUTH=user:password
JENKINS_URL=http://localhost:8080
```

the basic working command:

```sh
$ docker run -d \
    --net host \
    -e JENKINS_URL=http://jenkins.internal.domain:8080 \
    -e JENKINS_AUTH=registrator:1234567890123456789012  \
    dagar/jenkins-auto-slave
```

> Mounting of `/var/jenkins_home` volume is required in order for agent to be able to build jobs.

below command will also permit the slave run docker commands:

```sh
$ docker run -d \
    --net host \
    -e JENKINS_URL=http://jenkins.internal.domain:8080 \
    -e JENKINS_AUTH=registrator:1234567890123456789012  \
    -v /run/docker.sock:/run/docker.sock \
    -v /usr/bin/docker:/usr/bin/docker \
    simenduev/jenkins-auto-slave
```


Example: px4fmu-v2

```sh
$ docker run \
        --rm \
        --detach \
        --device=/dev/serial/by-id/usb-Black_Sphere_Technologies_Black_Magic_Probe_E2C3DAC5-if00 \
        --device=/dev/serial/by-id/usb-Black_Sphere_Technologies_Black_Magic_Probe_E2C3DAC5-if02 \
        -e JENKINS_AUTH=px4buildbot:d0b7b7496f8ac358729cd5685762b491 \
        -e JENKINS_SLAVE_LABELS="px4fmu-v2" \
        -e JENKINS_SLAVE_NAME=hil \
        -e JENKINS_URL=http://ci.px4.io:8080 \
        danielagar/docker-jenkins-auto-slave:latest
```

***
