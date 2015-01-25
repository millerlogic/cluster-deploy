#!/bin/bash

# ssh to the remote host as the deploy user.
# any arguments given are passed directly to ssh.

SDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

cd $SDIR

source load-vars-remote-host.sh

shift;

ssh -i ~/.ssh/id_rsa_cluster -o PasswordAuthentication=no -q deploy@$REMOTE_HOST "$@"
