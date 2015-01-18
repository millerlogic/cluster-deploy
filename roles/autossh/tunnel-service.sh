#!/bin/bash

action="$1"
tunnel="$2" # like: -L 3333:localhost:4444 -L 4444:localhost:5555 autossh@host1
cname="$3" # optional container name, or creates one based on $tunnel.
# If you don't name your tunnel container, be sure to stop the service before making changes.
if [ x"$cname" == "x" ]; then
	cname="$CONTAINER_SCOPE-tunnel"$(echo "$tunnel" | sed 's/[^0-9a-zA-Z][^0-9a-zA-Z]*/_/g')
fi
shift; shift; shift; # Other args are passed to the container. Such as --net=container:name
imgname="millerlogic/autossh"

SDIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

if [ x"$action" == x"install" ] || [ x"$action" == x"start" ]; then
	
	$BASE_DIR/roles/docker-container/build-image.sh "$imgname" "$SDIR" || exit 2
	
#else
	#
fi

$BASE_DIR/roles/docker-container/service-immutable.sh "$action" "$cname" "$imgname" \
    -v "/var/lib/autossh:/var/lib/autossh" \
    -v "/etc/hosts:/etc/hosts:ro" \
    -e AUTOSSH_ARGS="$tunnel" \
    "$@"
