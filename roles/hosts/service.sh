#!/bin/bash

# Adds your cluster's config/hosts file to the /etc/hosts file.

SDIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

if [ x"$1" == x"install" ]; then
	
	(
		fgrep -v '#auto#' /etc/hosts
		echo "# BEGIN - Do not edit this block of hosts or the #auto# comments"
		while read line; do
			echo "$line #auto#"
		done <$CLUSTER_CONFIG_DIR/hosts
		echo "#  END  - Do not edit this block of hosts or the #auto# comments"
	) >$LOCAL_DATA_DIR/newhosts
	
	cp -f /etc/hosts $LOCAL_DATA_DIR/oldhosts
	cp -f $LOCAL_DATA_DIR/newhosts /etc/hosts
	
fi
