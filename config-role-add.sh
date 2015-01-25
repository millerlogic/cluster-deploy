#!/bin/bash

# Usage: <host> [<role-priority>]
# <role-priority> is optional, can be a number from 1 to 9999 for an explicit role start order.

SDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

cd $SDIR

source $SDIR/load-vars-remote-host.sh

echo "Roles available: $(find "$CLUSTER_DIR/roles" "$SDIR/roles" \
    -maxdepth 1 -mindepth 1 -type d -exec basename {} \; | tr $'\n' ' ')"

echo
echo "Enter the name of the role to add:"
read rolename x
if [ x"$rolename" == "x" ]; then
	echo Error >&2
	exit 4
fi

role_priority_prefix=""
if [ x"$2" != "x" ]; then
	role_priority_prefix="#$(printf "%04d" "$2")-"
fi

filepath="$HOST_DIR/$role_priority_prefix$rolename.sh"
if [ -f "$filepath" ]; then
	read -p "This host already has this role, overwrite? (yes/no) " choice
	if [ x"$choice" != x"yes" ]; then
		exit
	fi
fi

role_loc1="$CLUSTER_DIR/roles/$rolename"
role_loc2="$SDIR/roles/$rolename"

role_find=""
if [ -d "$role_loc1" ]; then
	role_find="$role_find $role_loc1/*.sh"
fi
if [ -d "$role_loc2" ]; then
	role_find="$role_find $role_loc2/*.sh"
fi
if [ x"$role_find" == "x" ]; then
	echo "Role $rolename not found at either location:" >&2
	echo "$role_loc1" >&2
	echo "$role_loc2" >&2
	exit 5
fi

numservices=$(egrep --files-with-matches '^#ROLE_USAGE: ' $role_find | wc -l)
if [ x"$numservices" == x"0" ]; then
	echo "Not able to find a service script with a usage." >&2
	exit 6
fi
servicefile=
if [ x"$numservices" == x"1" ]; then
	servicefile=$(egrep --files-with-matches '^#ROLE_USAGE: ' $role_find)
	echo "Found service file: $servicefile"
else
	echo "Multiple usable service files found:"
	egrep --files-with-matches '^#ROLE_USAGE: ' $role_find | cat
	echo "Please enter one of them:"
	read servicefile
fi

full_usage=$(egrep -h '^#ROLE_USAGE: ' $servicefile | head -1 | cut -d' ' -f2-)
usage=$(echo "$full_usage" | cut -d'#' -f1 | sed -e 's/ *$//')
usage_comment=$(echo "$full_usage" | cut -d'#' -f2- | sed -e 's/^ *//')

echo
echo "Role $rolename"
echo "Role usage: $usage"
echo "Details: $usage_comment"
echo

serviceargs=
if [ x"$usage" == x"auto" ] || [ x"$usage" == "x" ]; then
	echo "The service does not appear to need parameters, you can press enter:"
	read serviceargs
else
	echo "The service needs you to abide by the role usage shown above."
	echo "You should enter any parameters needed as they would be entered in a script file."
	echo "I have generated the below example parameters for you to consider:"
	for arg in $(echo "$usage" | awk -F' \\| ' '{print $(NF)}'); do
		if [[ $arg == *"-state"* ]]; then
			echo -n '"$HOST_DIR/'"$rolename"'-state" '
		elif [[ $arg == *"-dir"* ]]; then
			echo -n '"$HOST_DIR/'"$rolename"'-data" '
		elif [[ $arg == *"-port"* ]]; then
			echo -n "$(( ((RANDOM<<15)|RANDOM) % 50001 + 2000 )) "
		elif [[ $arg == *"-num"* ]]; then
			echo -n "$RANDOM "
		elif [[ $arg == *"["* ]]; then
			echo -n "optional-$(echo "$arg" | tr -d ' <>[]|') "
		else
			echo -n "required-$(echo "$arg" | tr -d ' <>[]|') "
		fi
	done
	echo
	echo
	echo "Please enter your parameters for this role's service:"
	read serviceargs
fi

echo '#!/bin/bash
$(get-role-dir '"$rolename"')/'"$(basename $servicefile)"' "$1" '"$serviceargs" >$filepath

echo "Role added for $1 to file: $filepath"
