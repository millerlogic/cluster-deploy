#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

find $BASE_DIR/local-data/deployed-apt-update -mtime +1 -delete 2>/dev/null || echo
if [ ! -f $BASE_DIR/local-data/deployed-apt-update ]; then
	touch $BASE_DIR/local-data/deployed-apt-update

	apt-get update -y
	echo | apt-get upgrade -y

	apt-get install apt dpkg aptitude -y
	apt-get install daemon -y

fi
