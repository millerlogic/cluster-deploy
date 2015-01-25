#!/bin/bash
#ROLE_USAGE: auto # Ensure ssh setup on the remote host.

SDIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

if [ x"$1" == x"install" ]; then
	apt-get install openssh-client openssh-server -y
	/etc/init.d/ssh start
	if [ ! -f ~root/.ssh/id_rsa.pub ]; then
		ssh-keygen -t rsa -N "" -f ~root/.ssh/id_rsa
	fi
	#echo "###PUBKEY:$HOSTNAME###"
	#cat ~root/.ssh/id_rsa.pub
#else
	# Not doing this! We don't want to stop ssh.
	#/etc/init.d/ssh "$1"
fi
