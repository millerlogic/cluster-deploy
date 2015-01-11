#!/bin/bash

# Note: remember that the main service logs all service calls,
# so this output will be re-logged each time you request it.

cname="$1" # Container name.

if [ x"$cname" == "x" ]; then
	echo "Invalid container usage" >&2
	exit 4
fi

SDIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

docker logs "$cname"
