#!/bin/bash
# Created by: daniel ernesto lopez barron
# University of Missouri Kansas City
# April 28 2016

# PARAMS
# server nodePrefix,start,end user,password
# Ej: nm node-,1,4 dl544,daniel 

#UPDATED
scriptUsage(){
	echo "USAGE: Master.sh <server> <nodePrefix,start,end> <user,password>"
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

if [ $# -lt 3 ]
then
	scriptUsage
	exit 1
fi

if [ $# -gt 3 ]
then
	scriptUsage
	exit 1
fi




serverName=$1
nodePrefix=`echo $2 | cut -d, -f1`
startNode=`echo $2 | cut -d, -f2`
lastNode=`echo $2 | cut -d, -f3`
user=`echo $3 | cut -d, -f1`
password=`echo $3 | cut -d, -f2`

echo " "
echo ">> Configuring the master node STARTS"
./Step1.sh $serverName "$nodePrefix,$startNode,$lastNode" "$user,$password"
echo ">>  Configuring the master node DONE "
echo " "

server="$user@$serverName"
passCommand="sudo sshpass -p \"$password\""
optHostCheck="-o StrictHostKeyChecking=no"
optKey="-i ~/.ssh/id_dsa.pub"

echo " "
echo ">> Copying the scripts to the nodes STARTS"
for node in `seq $startNode $lastNode`;
do
	sshCommand="$passCommand $optHostCheck scp ./Step1.sh $nodePrefix$node:~"
	eval $sshCommand
done
echo ">> Copying the scripts to the nodes DONE"
echo " "


echo " "
echo ">> Executing the script in the nodes STARTS"
for node in `seq $startNode $lastNode`;
do
	ssh -t $nodePrefix$node ./Step1.sh $serverName "$nodePrefix,$startNode,$lastNode" "$user,$password"
done
echo ">> Executing the script in the nodes DONE"
echo " "
