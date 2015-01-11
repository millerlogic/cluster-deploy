#!/bin/bash

cname="$1" # Container name.

docker stop "$cname" || echo Already stopped >&2
