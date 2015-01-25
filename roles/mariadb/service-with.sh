#!/bin/bash
#ROLE_USAGE: <config-dir> <set-password> # Create mariadb (mysql) database.

action="$1"
CONFIG_DIR="$2"
passwd="$3"
shift; shift; shift;

SDIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

if [ x"$action" == x"install" ]; then
	$SDIR/install-with.sh "$CONFIG_DIR" "$passwd" "$@"
elif [ x"$action" == x"start" ]; then
	$SDIR/start-with.sh
elif [ x"$action" == x"stop" ]; then
	$SDIR/stop.sh
fi
