#!/bin/bash

cname="$1" # Container name.

# This can be a drop-in replacement for "stop" for immutable containers.
# In such case, "install" should also be used for "start".

SDIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

$SDIR/stop-container.sh "$cname"

docker rm "$cname" || echo Already removed >&2
