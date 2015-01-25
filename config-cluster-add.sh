#!/bin/bash

SDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

cd $SDIR

echo "Please enter a name for the new cluster:"
read clustername x
if [ x"$clustername" == "x" ]; then
	echo Error >&2
	exit 2
fi

echo "Enter a directory path for the cluster, or hit enter to use $SDIR/../$clustername-deploy:"
read clusterdir x
if [ x"$clusterdir" == "x" ]; then
	clusterdir=../$clustername-deploy
fi

mkdir -p $clusterdir &&
mkdir $clusterdir/hosts &&
mkdir $clusterdir/config &&
mkdir $clusterdir/roles &&
echo "$clustername=$clusterdir" >>clusters.conf &&
echo "Cluster setup, use config-cluster-host-add.sh to add hosts."
