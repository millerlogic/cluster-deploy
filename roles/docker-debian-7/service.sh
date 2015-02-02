#!/bin/bash
#ROLE_USAGE: auto | [<default-docker-opts>] # Role which allows using docker.

SDIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

if [ x"$1" == x"install" ] || [ x"$1" == x"start" ]; then
	shift;
	exec $SDIR/install.sh "$@"
fi
