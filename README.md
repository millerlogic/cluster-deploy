# cluster-deploy
Cluster deployment for roles, scripts and other configuration.

A collection of shell scripts in a familiar init.d style control mechanism with deployment, installation and configuration faclilities for clusters.

Main concepts:
* ```Host``` - one node in a cluster.
* ```Cluster``` - a logical collection of hosts.
* ```Role``` - a behavior which can run scripts on a host.
* ```Deploy``` - sending cluster files to a host and running install scripts on each role.
* ```Cluster config``` - config which is set by hosts and is propagated to the cluster on deployment.
* ```Service``` - init.d style service, responds to start, stop, as well as install.

Scripts:
* ```deploy-remote-host.sh [<user>@]<host>``` - sends the cluster files and role information to a host and installs.
* ```install-host.sh``` - this is run automatically by deploy-remote-host.sh on the remote host.
* ```load-vars-remote-host.sh``` - used by the other scripts to derive and source variables.
* ```main-service.sh <action> [<role>]``` ... - the main cluster-deploy /etc/init.d service deployed on hosts.
* ```service-remote-host.sh <action> [<role>]``` ... - a way to control the service (main-service.sh) on a remote host.

Clusters:
* ```clusters-example.conf``` - example file pointing to cluster directories.
* ```clusters.conf``` - actual file pointing to your cluster directories.

Cluster Directory:
* ```roles``` - directory similar to the main roles directory, but can contain roles local to the cluster. ```roles``` directory simply defines what are possible roles; a role is not actually used until a host references it.
* ```config``` - configuration for the cluster. See also cluster config.
* ```hosts``` - directory containing a sub-directory per host in the cluster.
* ```hosts/<host>``` - the host sub-directory declares which roles are actually used by the host, they are *.sh shell scripts similar to init.d services. The scripts can either add new functionality or call into the other roles, such as by calling a script in the ```roles``` directory. The scripts are run in alphabetical order, so a numbering scheme can be used when order is important, such as #0010-apt-update.sh and #0020-docker-debian-7.sh. A host's sub-directory can also contain further sub-directories if any additional data or configs are needed during deployment.

Builtin Roles:
* TBD - see the roles directory and check out the script source.

Roles API:
* ```$BASE_DIR``` - base directory of cluster-deploy deployed to a host.
* ```$HOST_DIR``` - directory containing this host's roles deployed to a host, it's the same as ```hosts/<host>``` from the cluster directory.
* ```$CLUSTER_CONFIG_DIR``` - the cluster config directory deployed to a host, it's the same as ```config``` from the cluster directory.
* ```$LOCAL_DATA_DIR``` - local data for use on a deployed host. For scratch data, install temp files, working area, etc. This data will die with the host, so anything permanent needs to be saved elsewhere.
* ```get-role-dir <role>``` - function to get a role directory by its name, since there are two different roles directories (builtin and cluster specific).
* ```###clusterconfig###<key>=<value>``` - a script which prints this notation can set a cluster config variable during deployment. It will propagate back to the caller and write a file under the cluster's ```config``` directory. From there the config can then be deployed to other hosts.

Example:
```
$ cd /home/wolf
$ mkdir wolf-cluster
$ git clone https://github.com/millerlogic/cluster-deploy.git
$ cat cluster-deploy/clusters.conf
wolf=../wolf-cluster
$ ls wolf-cluster
config  hosts  roles
$ ls wolf-cluster/hosts
wolfhost001  wolfhost002
$ ls wolf-cluster/hosts/wolfhost001
#0010-apt-update.sh #0020-docker-debian-7.sh #0050-autossh.sh 
#0012-hosts.sh #0030-ssh.sh #0200-mariadb-master-1of2.sh
#0040-tools.sh #0300-postfix.sh postfix-config mariadb-master-1of2-config
$ cat wolf-cluster/hosts/wolfhost001/\#0012-hosts.sh
#!/bin/bash
$BASE_DIR/roles/hosts/service.sh "$@"
```
