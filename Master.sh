#!/bin/bash
# Created by: daniel ernesto lopez barron
# University of Missouri Kansas City
# April 28 2016

# PARAMS
# nodePrefix,start,end user,password
# Ej: nm node-,1,4 dl544,daniel 

#UPDATED
scriptUsage(){
	echo "USAGE: Master.sh <server> <nodePrefix,start,end> <user,password>"
	echo "	+ nodePrefix: Corresponds with the prefix of the cluster's Datanodes"
	echo "	+ startNode: First datanode, naming must follow a sequential convention"
	echo "	+ lastNode: Last datanode, naming must follow a sequential convention"
	echo "	+ user: User that will manage the cluster"
	echo "	+ password: User's password"
	echo "	"
	echo "	"
	echo "	It is assume that the script is executed in the NameNode."
	echo "	Example: Master.sh nm cp-,1,3 doe,userpass"
	echo "	Will configure the cluster as user \"doe\" with password \"userpass\""
	echo "	With \"nm\" as Namenode and cp-1, cp-2, cp-3 as Datanodes"
}

if [ $# -ne 2 ]
then
	scriptUsage
	exit 1
fi



# SET PARAMETERS
nodePrefix=`echo $1 | cut -d, -f1`
startNode=`echo $1 | cut -d, -f2`
lastNode=`echo $1 | cut -d, -f3`
user=`echo $2 | cut -d, -f1`
password=`echo $2 | cut -d, -f2`

printf "\n>> Configuring the master node STARTS\n"
./Step1.sh "$nodePrefix,$startNode,$lastNode" "$user,$password"
printf "\n>>  Configuring the master node DONE\n\n"

passCommand="sudo sshpass -p \"$password\""
optHostCheck="-o StrictHostKeyChecking=no"
optKey="-i ~/.ssh/id_dsa.pub"

printf "\n>> Copying the scripts to the nodes STARTS\n"
for node in `seq $startNode $lastNode`;
do
	cmd="scp ./Step1.sh $nodePrefix$node:~ "
	sshCommand="$passCommand $cmd"

	echo $sshCommand
	eval $sshCommand
done
printf "\n>> Copying the scripts to the nodes DONE\n\n"

printf "\n>> Executing the script in the nodes STARTS\n"
for node in `seq $startNode $lastNode`;
do
	cmd="ssh -t $nodePrefix$node $optHostCheck $optKey ./Step1.sh $nodePrefix,$startNode,$lastNode $user,$password"
	sshCommand="$passCommand $cmd "
	eval $sshCommand
done
printf "\n>> Executing the script in the nodes DONE\n"

