#!/bin/bash

# Note: if the image isn't in the registry, you need to build-image.sh first.

cname="$1" # Container name.
imgname="$2" # Image name.
shift; shift; # Remaining args "$@" are passed to docker create as-is.

if [ x"$imgname" == "x" ]; then
	echo "Invalid container usage" >&2
	exit 4
fi

SDIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

# Only create the container if it's not already there.
if ! docker inspect --format '{{ .Name }}' "$cname" 2>/dev/null; then
	
	ximgname=$(echo "$imgname" | tr '/' '@')
	if [ ! -f "$BASE_DIR/local-data/docker-container/$ximgname.built" ]; then
		# If it's not a built container, let's pull it.
		$SDIR/pull-image.sh "$imgname"
	fi
	
	docker create "$@" --name="$cname" $imgname
fi

$SDIR/start-container.sh "$cname"
