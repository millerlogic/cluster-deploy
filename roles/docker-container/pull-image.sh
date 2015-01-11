#!/bin/bash

# Helper script to pull an image.

imgname="$1" # Image to pull.

if [ x"$imgname" == "x" ]; then
	echo "Invalid pull container usage" >&2
	exit 4
fi

SDIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

docker pull $imgname
