#!/bin/bash
# Created by: daniel ernesto lopez barron
# University of Missouri Kansas City
# April 28 2016

# PARAMS
startNode=1
lastNode=8
user=dl544
nodeName="cp"
password="daniel"

echo " "
echo ">> Configuring the master node STARTS"
./Step1.sh
echo ">>  Configuring the master node DONE "
echo " "

server="$user@nm"
passCommand="sudo sshpass -p \"$password\""
optHostCheck="-o StrictHostKeyChecking=no"
optKey="-i ~/.ssh/id_dsa.pub"

echo " "
echo ">> Copying the scripts to the nodes STARTS"
for node in `seq $startNode $lastNode`;
do
	sshCommand="scp ./Step1.sh $nodeName-$node:~"
	eval $sshCommand
done
echo ">> Copying the scripts to the nodes DONE"
echo " "


echo " "
echo ">> Executing the script in the nodes STARTS"
for node in `seq $startNode $lastNode`;
do
	ssh -t $nodeName-$node ./Step1.sh
done
echo ">> Executing the script in the nodes DONE"
echo " "
