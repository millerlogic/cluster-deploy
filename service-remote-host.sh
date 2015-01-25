#!/bin/bash

# Control the service on the specified host.
# Usage: <host> <action> [...]
# such as myhost01 start app.sh

SDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

cd $SDIR

source load-vars-remote-host.sh

if [ x"$2" == "x" ]; then
	echo "Invalid usage" >&2
	exit 1
fi

# Since we already used the host, shift it out and we get the service args.
shift;

ssh -i ~/.ssh/id_rsa_cluster -o PasswordAuthentication=no -q deploy@$REMOTE_HOST \
    sudo -i /etc/init.d/cluster-deploy "$1" "\\$2"
# Note: lame workaround using \\ so ssh won't evaluate the first char.
