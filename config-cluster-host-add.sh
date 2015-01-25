#!/bin/bash

SDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

cd $SDIR

echo "Enter the name of the cluster to add to:"
read clustername x
if [ x"$clustername" == "x" ]; then
	echo Error >&2
	exit 2
fi

echo "Enter the name of the host:"
read newhost x
if [ x"$newhost" == "x" ]; then
	echo Error >&2
	exit 3
fi

echo "If you want to enter an IP address for this host please do so, otherwise press enter:"
read newhostip x

declare -A clusters='('$(
    grep -v '^ *#' clusters.conf |
        awk -F= '{ if($2) printf(" [%s]=%s", $1, $2); }'
    )' )'

clusterdir=
for xclustername in "${!clusters[@]}"; do
	if [ x"$xclustername" == x"$clustername" ]; then
		clusterdir=${clusters[$clustername]}
	fi
done
if [ x"$clusterdir" == "x" ]; then
	echo "Could not locate the cluster $clustername" >&2
	exit 5
fi

mkdir -p $clusterdir/hosts/$newhost || exit 10

if [ x"$newhostip" != "x" ]; then
	echo "$newhostip $newhost" >>$clusterdir/config/hosts
fi

echo "Host $newhost added to cluster $clustername, use config-role-add.sh to add roles"
