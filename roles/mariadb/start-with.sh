#!/bin/bash

SDIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

cname="$CONTAINER_SCOPE-mariadb"

if [ "`docker inspect --format '{{ .State.Running }}' "$cname"`" != "true" ]; then
	docker start $cname
else
	echo Already running
fi
