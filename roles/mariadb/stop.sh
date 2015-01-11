#!/bin/bash

cname="$CONTAINER_SCOPE-mariadb"

docker stop "$cname" || echo Already stopped >&2
