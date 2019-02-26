FROM ubuntu:18.04
LABEL maintainer="Daniel Agar <daniel@agar.ca>"

# those are allowed to be changed at build time`
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

ENV JENKINS_HOME=/tmp/jenkins \
    JENKINS_USER=${user}

COPY JLink_Linux_V642f_x86_64.deb /tmp/jlink.deb

RUN dpkg -i /tmp/jlink.deb && rm -rf /tmp/jlink.deb \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
	curl \
	default-jre-headless \
	dumb-init \
	gcc-arm-none-eabi \
	gdb \
	gdb-multiarch \
	git \
	libltdl7 \
	openssh-client \
	python-serial \
	screen \
	usbutils \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    \
    # Jenkins is run with user `jenkins`, uid = 1000
    # If you bind mount a volume from the host or a data container,
    # ensure you use the same uid
    && groupadd -g ${gid} ${group} \
    && useradd -d "$JENKINS_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user} \
    && usermod -a -G dialout ${user} \
    \
    # Tweak global SSH client configuration
    && sed -i '/^Host \*/a \ \ \ \ ServerAliveInterval 30' /etc/ssh/ssh_config \
    && sed -i '/^Host \*/a \ \ \ \ StrictHostKeyChecking no' /etc/ssh/ssh_config

COPY jenkins-slave /usr/local/bin/jenkins-slave
RUN chmod +x /usr/local/bin/jenkins-slave

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/usr/local/bin/jenkins-slave"]
