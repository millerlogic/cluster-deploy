#!/bin/bash

SDIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

if [ x"$1" == x"install" ] || [ x"$1" == x"start" ]; then
	exec $SDIR/install.sh
fi
