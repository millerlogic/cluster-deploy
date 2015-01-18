#!/bin/bash

CONFIG_DIR="$1"
passwd="$2"
shift; shift;

if [ x"$passwd" == "x" ]; then
	echo "Invalid mariadb usage" >&2
	exit 4
fi

SDIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

cname="$CONTAINER_SCOPE-mariadb"

# Only get the image and create the container if it's not already there.
if ! docker inspect --format '{{ .Name }}' "$cname" 2>/dev/null; then

	docker pull mariadb

	mysql_config_dir=$(readlink -f "$CONFIG_DIR")

	docker create -p 127.0.0.1:3306:3306 -v "$mysql_config_dir:/etc/mysql" \
	    -e "MYSQL_ROOT_PASSWORD=$passwd" --name="$cname" "$@" mariadb
fi

$SDIR/start-with.sh "$CONFIG_DIR"
