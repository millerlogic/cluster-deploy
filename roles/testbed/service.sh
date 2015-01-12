#!/bin/bash

# Gives you a testbed contanier for testing new potential roles.
# Warning: if you use docker in the testbed container, it accesses the host's docker!

cname=testbed
imgname="rastasheep/ubuntu-sshd:14.04"

$BASE_DIR/roles/docker-container/service-immutable.sh "$1" $cname $imgname \
    -p 127.0.0.1:1022:22 -v /var/run/docker.sock:/var/run/docker.sock

echo Use: ssh root@localhost -p 1022