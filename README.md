# SSHConfigure

This project aimed to reduce the configuration worked requiered at the initial part of any Hadoop related project. Where you need to configure every node in the cluster so they can share the ssh key and establish a trusted connection with eachother.

Before executing the shell scripts there are some issues that need to be known:
1. The project is in an eraly stage
2. It solves the system update part
3. It solves the ssh-copy-id part
4. Every node in the cluster needs to have the same password
5. Every node in the cluster needs to follow an specific patter: node-1, node-2, ..., node-n
6. The script has only been tested on Ubuntu 14.04.

## Running the script
The user need to change the PARAMS section in both scripts. This parameters include: user name, password, node naming convention and node range. Later, the user needs to assign execution permisions to both Master and Step1 scripts. Finally, the execution is done by:


```shell
$ ./Master.sh
```

