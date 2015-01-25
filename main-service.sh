#!/bin/bash

if [ x"$1" == "x" ]; then
	echo "Invalid usage" >&2
	exit 1
fi

export DEBIAN_FRONTEND=noninteractive
export EDITOR=cat
export TERM=dumb

SDIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)
cd $SDIR

export BASE_DIR="$SDIR"

export HOST_DIR=/cluster/hosts/`hostname --fqdn || hostname`

export CLUSTER_CONFIG_DIR=/cluster/config

# Local dir for scratch data, install temp files, working area, etc.
export LOCAL_DATA_DIR="$BASE_DIR/local-data"

export CONTAINER_SCOPE=persist-deploy

export LOGFILE=/var/log/cluster-deploy/main-service-`date +%Y%m%d`.log

function get_role_dir
{
	rolename="$1"
	if [ x"$rolename" != "x" ]; then
		if [ -d "$HOST_DIR/roles/$rolename" ]; then
			echo "$HOST_DIR/roles/$rolename"
			return 0
		elif [ -d "$BASE_DIR/roles/$rolename" ]; then
			echo "$BASE_DIR/roles/$rolename"
			return 0
		fi
	fi
	return 1
}
export -f get_role_dir

if [ ! -d $HOST_DIR ]; then
	echo "This host dir cannot be found, $HOST_DIR" >&2
	exit 1
fi

echo "[`date`]" "$@" | tee -a $LOGFILE

if [ x"$2" != "x" ]; then
	# If arg 2, run the script under hosts/$HOST_DIR/
	script=$HOST_DIR/$2
	if [ -f $script ]; then
		(
			sleep 1
			set -x
			$script "$1"
		) 2>&1 | tee -a $LOGFILE
	else
		echo "Not found: $script" >&2
		exit 3
	fi
else
	for script in $HOST_DIR/*.sh; do
		(
			sleep 1
			set -x
			$script "$1"
		) 2>&1 | tee -a $LOGFILE
	done
fi
