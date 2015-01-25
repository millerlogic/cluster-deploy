#!/bin/bash

# user@host
ORIG_REMOTE=$1
ORIG_REMOTE_HOST=`echo $ORIG_REMOTE | egrep -o '[^@]+$'`
ORIG_REMOTE_USER=`echo $ORIG_REMOTE | fgrep '@' || echo root | egrep -o '^[^@]+'`

REMOTE_HOST=$ORIG_REMOTE_HOST
REMOTE=$ORIG_REMOTE
REMOTE_USER=$ORIG_REMOTE_USER

if [ x"$ORIG_REMOTE" == "x" ]; then
	echo "Which host?" >&2
	exit
fi

SDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

cd $SDIR

# Load up the cluster paths.
declare -A clusters='('$(
    grep -v '^ *#' clusters.conf |
        awk -F= '{ if($2) printf(" [%s]=%s", $1, $2); }'
    )' )'
#echo ${clusters[@]}

# Load any config/hosts files.
for clustername in "${!clusters[@]}"; do
	clusterdir=${clusters[$clustername]}
	if [ -f "$clusterdir/config/hosts" ]; then
		grep -v '^ *#' "$clusterdir/config/hosts" |
			awk '{ if($2) { sub(/\./, "_", $2); printf("host_%s=%s\n", $2, $1); } }'
	fi
done >hostvars$$
while read line; do
	declare "$line"
done <hostvars$$
rm -f hostvars$$

# See if we need to use one of the hosts.
remote_host_xname=host_$(echo "$REMOTE_HOST" | tr '.' '_')
if [ x"`eval echo ${!remote_host_xname}`" != "x" ]; then
	REMOTE_HOST=`eval echo ${!remote_host_xname}`
	REMOTE=$REMOTE_HOST
	if [ x"$REMOTE_USER" != "x" ]; then
		REMOTE="$REMOTE_USER@$REMOTE_HOST"
	fi
	echo "Found $ORIG_REMOTE_HOST to be $REMOTE_HOST" >&2
fi

# Find which cluster $ORIG_REMOTE_HOST belongs to.
CLUSTER=
CLUSTER_DIR=
HOST_DIR=
for clustername in "${!clusters[@]}"; do
	clusterdir=${clusters[$clustername]}
	if [ -d "$clusterdir/hosts/$ORIG_REMOTE_HOST" ]; then
		CLUSTER="$clustername"
		CLUSTER_DIR="$clusterdir"
		HOST_DIR="$clusterdir/hosts/$ORIG_REMOTE_HOST"
	fi
done
if [ x"$CLUSTER" == "x" ]; then
	echo "Was not able to find host $REMOTE_HOST in any of the configured clusters" >&2
	echo "The host name provided must match the cluster hosts dir exactly." >&2
	exit 6
fi
echo "Found $ORIG_REMOTE_HOST in cluster $CLUSTER" >&2

mkdir -p $CLUSTER_DIR/config # This dir is needed for auto clusterconfig.


# Ensure the current machine has a cluster key.
#apt-get install openssh-client openssh-server -y || exit
if [ ! -f ~/.ssh/id_rsa_cluster ]; then
	echo "Enter a new ssh key password for the cluster:"
	read $sshp
	ssh-keygen -t rsa -N "$sshp" -f ~/.ssh/id_rsa_cluster || exit
	sshp=
fi

# Assume they have an ssh-agent running,
# since starting it here would be pointless.
ssh-add -t 600 ~/.ssh/id_rsa_cluster || echo "Next time use ssh-agent and I'll cache your credentials" >&2

