#!/bin/bash
# Created by: daniel ernesto lopez barron
# University of Missouri Kansas City
# April 28 2016

# PARAMS
# TODO dev Remove this features so it can be passed as
# 		   arguments to the script


# PARAMS
# server nodePrefix,start,end user,password
# Ej: nm node-,1,4 dl544,daniel 

#UPDATED
scriptUsage(){
	echo "USAGE: Step1.sh <server> <nodePrefix,start,end> <user,password> <source>"
	echo "	+ server: Indicates the name of the server node (i.e. Hadoop's Namenode)"
	echo "	+ nodePrefix: Corresponds with the prefix of the cluster's Datanodes"
	echo "	+ startNode: First datanode, naming must follow a sequential convention"
	echo "	+ lastNode: Last datanode, naming must follow a sequential convention"
	echo "	+ user: User that will manage the cluster"
	echo "	+ password: User's password"
	echo "	"
	echo "	Edit the source file previous to run the Master.sh script"
	echo "	Example: Master.sh nm cp-,1,3 doe,userpass"
	echo "	Will configure the cluster as user \"doe\" with password \"userpass\""
	echo "	With \"nm\" as Namenode and cp-1, cp-2, cp-3 as Datanodes"
}

serverName=$1
nodePrefix=`echo $2 | cut -d, -f1`
startNode=`echo $2 | cut -d, -f2`
lastNode=`echo $2 | cut -d, -f3`
user=`echo $3 | cut -d, -f1`
password=`echo $3 | cut -d, -f2`


printf "\n>> Script to initialize a node\n ##----------------------------\n >> System update STARTS\n"
sudo apt-get -y update
sudo apt-get -y install default-jdk ssh rsync sshpass
update-alternatives --config java 

printf ">> System update FINISHED\n\n"

printf "\n>> Generating keys STARTS\n"
ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa 

passwordCmd="sshpass -p \"$password\""
sshkeyFile="~/.ssh/id_rsa.pub"

cmd="$passwordCmd ssh-copy-id -i $sshkeyFile $user@$serverName"
eval $cmd

for node in `seq $startNode $lastNode`;
do
	server="$user@$nodePrefix$node"
	cmd="$passwordCmd ssh-copy-id -i $sshkeyFile $server"
	echo "Sending keys to: $server"
	eval $cmd &

	wait 1%
done

chmod 0600 ~/.ssh/authorized_keys 

#eval $cmd
printf "\n>> Generating keys FINISHED"


