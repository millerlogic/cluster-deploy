#!/bin/bash
#ROLE_USAGE: auto # Installs common tools you might need on the host for installing other roles.

if [ x"$1" == x"install" ]; then
	apt-get install apt dpkg aptitude -y
	apt-get install cron -y
	apt-get install wget curl -y
	apt-get install git subversion -y
	apt-get install gcc make -y
	apt-get install build-essential pkg-config -y
fi
