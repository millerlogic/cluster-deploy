#!/bin/bash

# $1 is like: -L 3333:localhost:4444 -L 4444:localhost:5555  autossh@host1

SDIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

FN=/etc/default/autossh
TFN=`tempfile`

set -e

$SDIR/remove-tunnel.sh "$1" "-quiet"

cp "$FN" "$TFN"
echo "tunnel $1" >> "$TFN"
cp -f "$TFN" "$FN"
rm "$TFN"

echo "Tunnel added to config, sending start signal"
$SDIR/service.sh start ||
	echo "If a tunnel config is changed, the autossh service may need a restart"
