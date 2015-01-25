#!/bin/bash
#ROLE_USAGE: auto | [<email>] # Runs munin node and munin master on the host.

# If you don't want the master on the same machine, don't use this role.

# Put your e-mail address as the 2nd parameter and we'll setup some notifications.
# Test the following to ensure email works: echo "it works" | mail -s "email test" your@email

SDIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

if [ x"$1" == x"install" ]; then
	apt-get install munin-node munin -y
	# Patch the config to use the correct hostname:
	host_name=`hostname --fqdn || hostname`
	hostline="host_name $host_name"
	if ! fgrep "$hostline" /etc/munin/munin-node.conf >/dev/null; then
		(
			egrep -v "^host_name " /etc/munin/munin-node.conf;
			echo "$hostline";
		) > /etc/munin/munin-node-new.conf
		mv /etc/munin/munin-node.conf /tmp/munin-node.conf.`date +%s`.old
		mv /etc/munin/munin-node-new.conf /etc/munin/munin-node.conf
	fi
	hostgroup="[$host_name]"
	if fgrep "[localhost.localdomain]" /etc/munin/munin.conf >/dev/null; then
		(
			cat /etc/munin/munin.conf | while read line; do
				if [ x"$line" == x"[localhost.localdomain]" ]; then
					echo "$hostgroup"
				else
					echo "$line"
				fi
			done
		) > /etc/munin/munin-new.conf
		mv /etc/munin/munin.conf /tmp/munin.conf.`date +%s`.old
		mv /etc/munin/munin-new.conf /etc/munin/munin.conf
	fi
	if [ x"$2" != "x" ]; then
		kmem=`egrep '^MemTotal:' /proc/meminfo | awk '{print($2)}'`
		fs=`df -P "$SDIR" | tail -1 | awk '{print($1)}'`
		echo "
contacts munin_all
contact.munin_all.command mail -s \"\${var:host} alert: \${var:group}\" $2
contact.munin_all.always_send warning critical
[$host_name]
memory.apps.warning $(( $kmem * 1000 * 92 / 100 ))
memory.apps.critical $(( $kmem * 1000 * 96 / 100 ))
cpu.idle.warning 10:
cpu.idle.critical 2:
df.$(echo "$fs" | sed -e 's/^[^A-Za-z_]/_/' -e 's/[^A-Za-z0-9_]/_/g').warning 80
df.$(echo "$fs" | sed -e 's/^[^A-Za-z_]/_/' -e 's/[^A-Za-z0-9_]/_/g').critical 90
" > /etc/munin/munin-conf.d/munin-all-notifications.conf
		echo "munin alert notifications enabled for $host_name to $2"
		if [ ! -f $BASE_DIR/local-data/munin-all/tested-email ]; then
			mkdir -p $BASE_DIR/local-data/munin-all
			touch $BASE_DIR/local-data/munin-all/tested-email
			echo "You are setup to receive munin alerts!" |
				mail -s "munin-all test email: $host_name" "$2"
			echo; echo " *** I just sent you a test email, please confirm you got it!"; echo;
			sleep 5
			echo; echo "If you didn't get the test email, please fix. I will NOT resend it."; echo;
			sleep 5
		fi
	fi
#else
	# Not doing anything else, we don't want to stop it.
fi

echo "Munin graphs at file:///var/cache/munin/www/index.html"
echo "Run the following to get munin graphs on the web server:"
echo "    ln -s /var/cache/munin/www /var/www/.munin-`hostname --fqdn || hostname`"
