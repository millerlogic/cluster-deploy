#!/bin/bash

cname="$1" # Container name.

if [ x"$cname" == "x" ]; then
	echo "Invalid container usage" >&2
	exit 4
fi

SDIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

if [ "`docker inspect --format '{{ .State.Running }}' "$cname"`" != "true" ]; then
	docker start $cname
else
	echo Already running
fi
