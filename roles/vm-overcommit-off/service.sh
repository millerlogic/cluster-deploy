#!/bin/bash

# Note: only use this if you're sure you don't want to use the oom-killer.
# Some programs DEPEND on overcommit, such as Java. In such cases, do not use this role.
# Documentation: https://www.kernel.org/doc/Documentation/vm/overcommit-accounting
# If using this role, consider also using swap.

if [ x"$1" == x"install" ] || [ x"$1" == x"start" ]; then
	sysctl -w vm.overcommit_memory=0 # Keeping it 0.
	sysctl -w vm.overcommit_ratio=0 &&
		echo "Overcommit ratio = 0"
elif [ x"$1" == x"status" ]; then
	sysctl vm.overcommit_memory
	sysctl vm.overcommit_ratio
elif [ x"$1" == x"stop" ]; then
	# Setting the default value:
	sysctl -w vm.overcommit_memory=0
	sysctl -w vm.overcommit_ratio=50
fi
