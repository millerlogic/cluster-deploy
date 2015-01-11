#!/bin/bash

if [ x"$2" == "x" ]; then
	echo "Invalid mariadb usage" >&2
	exit 4
fi

SDIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

cname="$CONTAINER_SCOPE-mariadb"

if [ "`docker inspect --format '{{ .State.Running }}' "$cname"`" != "true" ]; then
	docker start $cname
else
	echo Already running
fi
