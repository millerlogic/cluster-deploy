#!/bin/bash

CONFIG_DIR="$2"

SDIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

if [ x"$1" == x"install" ]; then
	$SDIR/install-with.sh "$CONFIG_DIR" "$3"
elif [ x"$1" == x"start" ]; then
	$SDIR/start-with.sh "$CONFIG_DIR" "$3"
elif [ x"$1" == x"stop" ]; then
	$SDIR/stop.sh
fi
