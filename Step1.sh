#!/bin/bash
echo " "
echo ">> Script to initialize a node"
echo "##----------------------------"
echo ">> System update STARTS"
sudo apt-get -y update  && sudo apt-get -y install default-jdk ssh rsync sshpass && update-alternatives --config java 
echo ">> System update FINISHED "
echo " "


echo " "
echo ">> Generating keys STARTS"
ssh-keygen -t dsa -P '' -N ' ' -f ~/.ssh/id_dsa && cat ~/.ssh/id_dsa.pub >> ~/.ssh/authorized_keys 
# ssh-keygen -t dsa -P '' -N ' ' -f ~/.ssh/id_dsa && cat ~/.ssh/id_dsa.pub >> ~/.ssh/authorized_keys && sudo ssh-copy-id -i ~/.ssh/id_dsa.pub dl544@nm && sudo ssh-copy-id -i ~/.ssh/id_dsa.pub dl544@cp-1 && sudo ssh-copy-id -i ~/.ssh/id_dsa.pub dl544@cp-2 && sudo ssh-copy-id -i ~/.ssh/id_dsa.pub dl544@cp-3

# Change this parameters
user=dl544
password="daniel"
lastNode=4
nodeName="cp"
server="$user@nm"

# Don't touch this parameters
passCommand="sudo sshpass -p \"$password\""
optHostCheck="-o StrictHostKeyChecking=no"
optKey="-i ~/.ssh/id_dsa.pub"

sshCopy="$passCommand ssh-copy-id $optHostCheck $optKey $server"
for node in `seq 1 $lastNode`;
do
	server="$user@$nodeName-$node"
	nextNode="&& $passCommand ssh-copy-id $optHostCheck $optKey $server"
	sshCopy="$sshCopy $nextNode"
done
eval $sshCopy
echo ">> Generating keys FINISHED"
echo ">> GO AND CONFIGURE THE NODES ...."

