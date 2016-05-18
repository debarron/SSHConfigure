#!/bin/bash
# nm node-,1,4 daniel,daniel

server=$1
nodePrefix=`echo $2 | cut -d, -f1`
start=`echo $2 | cut -d, -f2`
end=`echo $2 | cut -d, -f3`
user=`echo $3 | cut -d, -f1`
password=`echo $3 | cut -d, -f2`

echo " "
echo ">> THE CONFIG "
echo "
server: $server  \
pref:  $nodePrefix \
start: $start \
end: $end \
user: $user \
password: $password"