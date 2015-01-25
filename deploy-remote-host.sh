#!/bin/bash

# Call with a hostname; will connect, setup the repo and call install-host.sh on it.

SDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

cd $SDIR

source load-vars-remote-host.sh

id_rsa_cluster_pub=`cat ~/.ssh/id_rsa_cluster.pub`

echo "Deploying..."

#ssh-copy-id -i ~/.ssh/id_rsa_cluster $REMOTE
# Use the deploy user which can do passwordless sudo and ssh.
ssh -i ~/.ssh/id_rsa_cluster -o PasswordAuthentication=no -q deploy@$REMOTE_HOST echo ok ||
ssh -t $REMOTE '
	sudo -i /bin/bash -c "
		groupadd -g 28100 deploy || echo;
		useradd -s /bin/bash --create-home -u 28100 -N -g 28100 deploy || echo;
		sudo -u deploy mkdir -p ~deploy/.ssh;
		echo \"'"$id_rsa_cluster_pub"'\" > ~deploy/.ssh/authorized_keys;
		chown deploy:deploy ~deploy/.ssh/authorized_keys;
		echo \"deploy ALL=(ALL) NOPASSWD:ALL # '$HOSTNAME' \" > /etc/sudoers.d/deploy-remote;
		chmod 0400 /etc/sudoers.d/deploy-remote;
		mkdir -p /deploy;
		mkdir -p /cluster;
		chown deploy:root /deploy;
		chown deploy:root /cluster;
	" || exit 9
' || exit 9

rsync -uave 'ssh -i ~/.ssh/id_rsa_cluster' --exclude .git . deploy@$REMOTE_HOST:/deploy
rsync -uave 'ssh -i ~/.ssh/id_rsa_cluster' --exclude .git "$CLUSTER_DIR"/ deploy@$REMOTE_HOST:/cluster

ssh -i ~/.ssh/id_rsa_cluster deploy@$REMOTE_HOST 'sudo -i /bin/bash -c "cd /deploy && ./install-host.sh" ' |
	while read -r line; do
		echo "$line"
		if echo "$line" | fgrep '###clusterconfig###' >/dev/null; then
			echo "$line" | awk -F'###' '{ print $3 }' |
				while IFS='=' read -r key value; do
					echo "$key" | egrep '^[a-zA-Z0-9_\.]+$' >/dev/null &&
						echo "$value" >$CLUSTER_DIR/config/$ORIG_REMOTE_HOST-$key.conf
				done
		fi
	done
