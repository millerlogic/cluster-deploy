#!/bin/bash

SDIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

if [ x"$1" == x"install" ]; then
	apt-get install openssh-client openssh-server -y
	apt-get install autossh -y
	
	adduser -u 28105 --system --group --shell /bin/false \
		--home /var/lib/autossh --disabled-password autossh || echo
	sudo -u autossh /bin/sh -c '
		if [ ! -f ~/.ssh/id_rsa.pub ]; then
			ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
		fi
		echo "###clusterconfig###autossh.key=`cat ~/.ssh/id_rsa.pub`"
	'
	
	SCRATCH=$LOCAL_DATA_DIR/autossh/scratch
	mkdir -p $SCRATCH
	
	(
		cd $SCRATCH
		if cd autossh-init; then
			echo ok
		else
			git clone https://github.com/obfusk/autossh-init.git
			cd autossh-init
		fi
		git checkout f6fb0188023bc26aa34d784cfa880004ad8a129c || exit 2 # known good version
		cp autossh.init /etc/init.d/autossh
		echo "
AUTOSSH_USER=autossh
autossh_opts -M 0 -q -N -f -o ServerAliveCountMax=3 \
    -o ServerAliveInterval=20 -o StrictHostKeyChecking=no
# This file gets deleted and re-created each cluster-deploy install!
" >/etc/default/autossh
	)
	
	# Copy in the autossh pubkeys from the cluster config.
	mkdir -p ~autossh/.ssh
	cat $CLUSTER_CONFIG_DIR/*-autossh.key.conf |
		while read line; do
			echo "command=\"/bin/false\",no-agent-forwarding,no-pty,no-X11-forwarding $line"
		done >~autossh/.ssh/authorized_keys
	chown -R autossh:autossh ~autossh/.ssh
	
	/etc/init.d/autossh start
	
else
	/etc/init.d/autossh "$1"
fi
