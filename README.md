# cluster-deploy
Cluster deployment for roles, scripts and other configuration

Main concepts:
* Host - one node in a cluster.
* Cluster - a logical collection of hosts.
* Role - a behavior which can run scripts on a host.
* Deploy - sending cluster files to a host and running install scripts on each role.
* Cluster config - config which is set by hosts and is propagated to the cluster on deployment.
* Service - init.d style service, responds to start, stop, as well as install.

Scripts:
* deploy-remote-host.sh [<user>@]<host> - sends the cluster files and role information to a host and installs.
* install-host.sh - this is run automatically by deploy-remote-host.sh on the remote host.
* load-vars-remote-host.sh - used by the other scripts to derive and source variables.
* main-service.sh <action> [<role>] ... - the main cluster-deploy /etc/init.d service deployed on hosts.
* service-remote-host.sh <action> [<role>] ... - a way to control the service (main-service.sh) on a remote host.


