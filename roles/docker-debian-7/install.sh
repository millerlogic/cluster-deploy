#!/bin/bash

if [ x"$1" != "x" ]; then
	echo "DOCKER_OPTS=\"$1\"" >/etc/default/docker
fi

if ! command -v docker; then
	apt-get install curl -y || echo
	echo | curl -sSL https://get.docker.com/ | sh
fi

# Let the deploy user control docker.
usermod -a -G docker deploy || true

# Setup standard user for containers.
groupadd -g 28101 container || echo
useradd -u 28101 -N -g 28101 container || echo
