#!/bin/bash

# $1 is like: -L 3333:localhost:4444 -L 4444:localhost:5555  autossh@host1

SDIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

FN=/etc/default/autossh
TFN=`tempfile`

set -e

cat "$FN" | fgrep -v -- "tunnel $1" > $TFN
cp -f "$TFN" "$FN"
rm "$TFN"

if [ x"$2" != x"-quiet" ]; then
	echo "Tunnel removed from config, service must be restarted to take effect"
fi
