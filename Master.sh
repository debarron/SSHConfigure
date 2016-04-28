#!/bin/bash

echo " "
echo ">> Configuring the master node STARTS"
./Step1.sh
echo ">>  Configuring the master node DONE "
echo " "


startNode=1
lastNode=8
user=dl544
nodeName="cp"
password="daniel"
server="$user@nm"
passCommand="sudo sshpass -p \"$password\""
optHostCheck="-o StrictHostKeyChecking=no"
optKey="-i ~/.ssh/id_dsa.pub"

echo " "
echo ">> Copying the scripts to the nodes STARTS"
for node in `seq $startNode $lastNode`;
do

	sshCommand="scp ./Step1.sh $nodeName-$node:~"
	# scp ./Step1.sh "$nodeName-$node:~"
	eval $sshCommand
done
echo ">> Copying the scripts to the nodes DONE"
echo " "



# echo ">> Executing the script in the nodes STARTS"
# echo " "
# for node in `seq $startNode $lastNode`;
# do
# 	ssh -t $nodeName-$node ./Step1.sh
# done
# echo ">> Executing the script in the nodes DONE"
# echo " "
