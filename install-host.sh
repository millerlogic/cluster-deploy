#!/bin/bash

# This is to be called locally on one of the hosts, it's called automatically by deploy-remote-host.sh

error() {
  local parent_lineno="$1"
  local message="$2"
  local code="${3:-1}"
  echo "Error $code near line $parent_lineno: $message"
  exit $code
}

trap 'error ${LINENO}' ERR

SDIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

SERVICE_FILE=/etc/init.d/cluster-deploy
#if [ ! -f $SERVICE_FILE ]; then
	echo "Installing service file $SERVICE_FILE..."
	echo '#!/bin/bash
### BEGIN INIT INFO
# Provides:          cluster-deploy
# Required-Start:    $syslog $remote_fs $network $time
# Required-Stop:     $syslog $remote_fs
# Default-Start:     2 3 5
# Default-Stop:      0 1 6
# Description:       Start all the deployed scripts for the host.
### END INIT INFO
'$SDIR'/main-service.sh "$@"
' > $SERVICE_FILE
	chmod +x $SERVICE_FILE
#fi

mkdir -p /var/log/cluster-deploy

# Ensure host has a key.
apt-get install openssh-client openssh-server -y
if [ ! -f ~root/.ssh/id_rsa.pub ]; then
	ssh-keygen -t rsa -N "" -f ~root/.ssh/id_rsa
fi

echo "Installing and starting roles..."
$SERVICE_FILE install

update-rc.d cluster-deploy defaults
update-rc.d cluster-deploy enable
