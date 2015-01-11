#!/bin/bash

# This will turn on swap with exactly the amount of memory you have.
# If swap is already on, it will add enough swap to match your memory.

SWAPFILE_DIR=$BASE_DIR/local-data/swap
SWAPFILE=$BASE_DIR/local-data/swap/swapfile

if [ x"$1" == x"install" ] || [ x"$1" == x"start" ]; then
	mkdir -p $SWAPFILE_DIR
	kmem=`egrep '^MemTotal:' /proc/meminfo | awk '{print($2)}'`
	kswap=`egrep '^SwapTotal:' /proc/meminfo | awk '{print($2)}'`
	kswapalloc=$(( $kmem - $kswap ))
	kleeway=128 # Don't bother with swap if the difference is small.
	if [ $kswapalloc -gt $kleeway ]; then
		echo "Allocating $kswapalloc kB swap space..."
		dd if=/dev/zero of="$SWAPFILE" bs=1000 count=$kswapalloc
		chmod 0600 "$SWAPFILE"
		mkswap "$SWAPFILE" && swapon -v "$SWAPFILE"
	else
		echo "You have enough swap ($kswap kB), not allocating more"
	fi
elif [ x"$1" == x"status" ]; then
	egrep '^Swap' /proc/meminfo
elif [ x"$1" == x"stop" ]; then
	swapoff -v "$SWAPFILE" && rm "$SWAPFILE" || echo
fi
