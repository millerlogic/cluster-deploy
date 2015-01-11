#!/bin/bash

if ! command -v docker; then
	apt-get install curl -y || echo
	echo | curl -sSL https://get.docker.com/ | sh
fi

# Setup standard user for containers.
groupadd -g 28101 container || echo
useradd -u 28101 -N -g 28101 container || echo
