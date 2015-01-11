#!/bin/bash

# Use this service controller if you want an immutable container with no important internal state.
# This is usually the preferred method so that containers are destroyed and never relied upon.
# Any state should be managed by the calling script or kept in separate volumes.

action="$1" # start/stop/etc
cname="$2" # Container name.
imgname="$3" # Image name.
shift; shift; shift; # Remaining args "$@" are passed to docker create as-is.

SDIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

if [ x"$action" == x"install" ]; then
	$SDIR/install-container.sh "$cname" "$imgname" "$@"
elif [ x"$action" == x"start" ]; then
	$SDIR/install-container.sh "$cname" "$imgname" "$@"
elif [ x"$action" == x"stop" ]; then
	$SDIR/rm-container.sh "$cname"
elif [ x"$action" == x"status" ]; then
	$SDIR/status-container.sh "$cname"
elif [ x"$action" == x"logs" ] || [ x"$action" == x"log" ]; then
	$SDIR/logs-container.sh "$cname"
else
	echo "Not handling $action" >&2
fi
