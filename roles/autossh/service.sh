#!/bin/bash
#ROLE_USAGE: auto # The main tunneling service needed on both sides of a potential tunnel.

# This service lets you use autossh tunnels, you need to use this role on both sides.
# Then use tunnel-service.sh to add the actual tunnels.

SDIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

if [ x"$1" == x"install" ]; then
	
	adduser -u 28105 --system --group --shell /bin/false \
		--home /var/lib/autossh --disabled-password autossh || echo
	sudo -H -u autossh /bin/sh -c '
		if [ ! -f ~/.ssh/id_rsa.pub ]; then
			ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
		fi
		echo "###clusterconfig###autossh.key=`cat ~/.ssh/id_rsa.pub`"
	'
	
	# Copy in the autossh pubkeys from the cluster config.
	mkdir -p ~autossh/.ssh
	cat $CLUSTER_CONFIG_DIR/*-autossh.key.conf 2>/dev/null |
		while read line; do
			echo "command=\"/bin/false\",no-agent-forwarding,no-pty,no-X11-forwarding $line"
		done >~autossh/.ssh/authorized_keys
	chown -R autossh:autossh ~autossh/.ssh
	
#else
	#
fi
