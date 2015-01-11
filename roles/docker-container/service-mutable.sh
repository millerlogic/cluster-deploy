#!/bin/bash

# Use this service controller if you need to preserve the contents of a container.
# Usually it's preferred to use immutable so that containers are destroyed and never relied upon.

action="$1" # start/stop/etc
cname="$2" # Container name.
imgname="$3" # Image name.
shift; shift; shift; # Remaining args "$@" are passed to docker create as-is.

SDIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

if [ x"$action" == x"install" ]; then
	$SDIR/install-container.sh "$cname" "$imgname" "$@"
elif [ x"$action" == x"start" ]; then
	$SDIR/start-container.sh "$cname"
elif [ x"$action" == x"stop" ]; then
	$SDIR/stop-container.sh "$cname"
elif [ x"$action" == x"status" ]; then
	$SDIR/status-container.sh "$cname"
elif [ x"$action" == x"logs" ] || [ x"$action" == x"log" ]; then
	$SDIR/logs-container.sh "$cname"
else
	echo "Not handling $action" >&2
fi
