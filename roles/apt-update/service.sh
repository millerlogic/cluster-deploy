#!/bin/bash
#ROLE_USAGE: auto # Ensures apt is updated and upgraded on the host.

SDIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

if [ x"$1" == x"install" ] || [ x"$1" == x"start" ]; then
	exec $SDIR/install.sh
fi
