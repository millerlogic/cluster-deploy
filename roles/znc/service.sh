#!/bin/bash
#ROLE_USAGE: <state-dir> [<host-port>] # Run znc in a container.

STATE_DIR="$2"
PORT="$3"
if [ x"$PORT" == "x" ]; then
	PORT=16660
fi

SDIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

cname="$CONTAINER_SCOPE-znc"
imgname="millerlogic/znc-container"

if [ x"$1" == x"install" ]; then
	# Need to build the image.
	SCRATCH=$LOCAL_DATA_DIR/znc/scratch
	mkdir -p $SCRATCH
	(
		cd $SCRATCH
		if cd znc-container; then
			echo ok
		else
			git clone https://github.com/millerlogic/znc-container.git
			cd znc-container
		fi
		git checkout 7ab7d22c43a77317e80ea74e28bf34ad136b7eb4 || exit 2 # known good version
	)
	$BASE_DIR/roles/docker-container/build-image.sh $imgname "$SCRATCH/znc-container"
fi

$BASE_DIR/roles/docker-container/service-immutable.sh "$1" "$cname" "$imgname" -v "$STATE_DIR:/znc-state" -p "$PORT:16660"

echo "znc is on port $PORT"
