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
	echo "USAGE: Step1.sh <server> <nodePrefix,start,end> <user,password>"
	echo "	+ server: Indicates the name of the server node (i.e. Hadoop's Namenode)"
	echo "	+ nodePrefix: Corresponds with the prefix of the cluster's Datanodes"
	echo "	+ startNode: First datanode, naming must follow a sequential convention"
	echo "	+ lastNode: Last datanode, naming must follow a sequential convention"
	echo "	+ user: User that will manage the cluster"
	echo "	+ password: User's password"
	echo "	"
	echo "	"
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
sudo apt-get -y update  && sudo apt-get -y install default-jdk ssh rsync sshpass && update-alternatives --config java 
printf ">> System update FINISHED\n\n"

printf "\n>> Generating keys STARTS\n"
echo -e 'y\n'|ssh-keygen -t dsa -P '' -N ' ' -f ~/.ssh/id_dsa && 
cat ~/.ssh/id_dsa.pub >> ~/.ssh/authorized_keys 
# ssh-keygen -t dsa -P '' -N ' ' -f ~/.ssh/id_dsa && cat ~/.ssh/id_dsa.pub >> ~/.ssh/authorized_keys && sudo ssh-copy-id -i ~/.ssh/id_dsa.pub dl544@nm && sudo ssh-copy-id -i ~/.ssh/id_dsa.pub dl544@cp-1 && sudo ssh-copy-id -i ~/.ssh/id_dsa.pub dl544@cp-2 && sudo ssh-copy-id -i ~/.ssh/id_dsa.pub dl544@cp-3

# Don't touch this parameters
passCommand="sshpass -p \"$password\""
optHostCheck="-o StrictHostKeyChecking=no"
optKey="-i ~/.ssh/id_dsa.pub"

sshCopy="echo \"Starts\" "
sshCopy="$passCommand ssh-copy-id $optHostCheck $optKey $user@$serverName"
for node in `seq $startNode $lastNode`;
do
	server="$user@$nodePrefix$node"
	nextNode="&& $passCommand ssh-copy-id $optHostCheck $optKey $server"
	sshCopy="$sshCopy $nextNode"
done
eval $sshCopy
printf "\n>> Generating keys FINISHED"

