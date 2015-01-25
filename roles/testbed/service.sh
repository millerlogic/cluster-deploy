#!/bin/bash
#ROLE_USAGE: auto | [<extra-docker-start-args>] # Test container; useful args include --link ...

# Gives you a testbed contanier for testing new potential roles.
# Warning: if you use docker in the testbed container, it accesses the host's docker!

action="$1"
cname=testbed
imgname="rastasheep/ubuntu-sshd:14.04"
shift; shift; shift;

$BASE_DIR/roles/docker-container/service-immutable.sh "$action" $cname $imgname \
    -p 127.0.0.1:1022:22 -v /var/run/docker.sock:/var/run/docker.sock "$@"

echo Use: ssh root@localhost -p 1022
