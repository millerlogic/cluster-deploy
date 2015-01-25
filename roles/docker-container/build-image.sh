#!/bin/bash

# Helper script to build an image that's not in the registry.
# You can call this from your role's install and start actions.

imgname="$1" # Name to give the built image, this is simply passed to --tag
path="$2" # Path or URL to the Dockerfile
shift; shift; # Remaining args "$@" are options passed to docker build as-is.

if [ x"$imgname" == "x" ]; then
	echo "Invalid build container usage" >&2
	exit 4
fi

SDIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

docker build --tag="$imgname" "$@" "$path" || exit 2

# Mark it as built so we don't try to pull it later.
mkdir -p $BASE_DIR/local-data/docker-container
ximgname=$(echo "$imgname" | tr '/' '@')
echo "'$imgname' '$path'" "$@" > "$BASE_DIR/local-data/docker-container/$ximgname.built"
