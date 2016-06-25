#!/bin/bash
# $1 masternode
# $2 datanodeConfig
# $3 userConfig


serverName=$1
nodePrefix=`echo $2 | cut -d, -f1`
startNode=`echo $2 | cut -d, -f2`
lastNode=`echo $2 | cut -d, -f3`
user=`echo $3 | cut -d, -f1`
password=`echo $3 | cut -d, -f2`
src=sources

outDN="datanode.tar.gz"
outMN="masternode.tar.gz"

hadoopDir="/hadoop/etc/hadoop/"
sparkDir="/spark/conf/"
hadoopCoreSite="$hadoopDir/core-site.xml"
hadoopYarnSite="$hadoopDir/yarn-site.xml"
hadoopMasters="$hadoopDir/masters"

# Read the config file
while read -r line
do
	suff="${line#*=}"
	pref="${line%=*}"

	if [ $pref == "datanode" ]
	then
		dn=$suff
	elif [ $pref == "masternode" ]
	then
		mn=$suff
	elif [ $pref == "sparkVersion" ]
	then
		spv=$suff
	elif [ $pref == "hadoopVersion" ]
	then
		hv=$suff
	elif [ $pref == "masterNetworkName" ]
	then
		masterNetworkName=$suff
	elif [ $pref == "scalaVersion" ]
	then
		scv=$suff
	fi

done < <(grep '' $src)

echo "#### Summerizing: "
echo "Spark Version $spv"
echo "Hadoop Version: $hv"
echo "Scala Version: $scv"
echo " "
echo " "

sysDir="/usr/local"
patternCoreSite="sed -e 's/.*<value>hdfs\([^<]*\)<\/value>.*/<value>hdfs\:\/\/$masterNetworkName<\/value>/g' "
patternYarnSite="sed -e 's/.*<value>nm\([^<]*\)<\/value>.*/<value>$masterNetworkName<\/value>/g' "


#Download the tar files for master and datanode
downloadDN="wget -c $dn -O $outDN"
downloadMN="wget -c $mn -O $outMN"
echo "### Downloading "
echo "Downlonding: $downloadMN"
echo "Downlonding: $downloadDN"
echo " "
echo " "
eval $downloadMN
eval $downloadDN


# UnTAR
untarDN="tar -xzf $outDN"
untarMN="tar -xzf $outMN"
echo "### UnTAR the files"
echo "UnTARing: $untarDN"
echo "UnTARing: $untarMN"
eval $untarMN
eval $untarDN
echo " "
echo " "


# Remove tars
removeDNT="rm $outDN"
removeMNT="rm $outMN"
echo "### Removing the TAR files"
echo "Removing: $removeMNT "
echo "Removing: $removeDNT "
eval $removeMNT
eval $removeDNT
echo " "
echo " "


# Change the values for the master
echo "### Applying sed to the configuration files"
location="masternode"
temCS="$location/$hadoopDir/core-site.xml.temp"
temYS="$location/$hadoopDir/yarn-site.xml.temp"
echo " "

echo "### Editin the core-site.xml file "
coreSiteCmd="$patternCoreSite $location/$hadoopCoreSite > $temCS"
moveCS="mv $temCS $location/$hadoopCoreSite"

eval $coreSiteCmd
eval $moveCS
echo " "

echo "### Editing the yarn-site.xml file "
yarnSiteCmd="$patternYarnSite $location/$hadoopYarnSite > $temYS"
moveYS="mv $temYS $location/$hadoopYarnSite"

eval $yarnSiteCmd
eval $moveYS
echo " "

echo "### Editing the masters file"
cmd="echo $serverName > $location/$hadoopMasters"
echo " "

echo "### Editing the slaves file"
slaves="$location/$hadoopDir/slaves"
echo " " > $slaves
for node in `seq $startNode $lastNode`;
do
	echo "$nodePrefix$node" >> $slaves
done
echo " "

echo "### Replicating the changes to masternode"
cmd="cp $slaves masternode/spark/conf/"
eval $cmd
echo " "

echo "### Moving the files to $sysDir"
location="masternode"
moveCmd="sudo cp $location/spark $sysDir/ && sudo cp $location/scala $sysDir/ && sudo cp $location/hadoop $sysDir/"
ownerCmd="sudo chown $user -R $sysDir/spark && sudo chown $user -R $sysDir/hadoop && sudo chown $user -R $sysDir/scala"
bashCmd="mv $location/bashrc.templete ~/.bashrc && source ~/.bashrc"

eval $moveCmd
eval $ownerCmd
eval $bashCmd

echo "### Masternode's files configured "
echo " "
echo " "


echo "### Replicating the changes to datanode"
location="datanode"
origin="masternode"
echo "### Copying core-site.xml "
cmd="cp $origin/$hadoopCoreSite $location/$hadoopCoreSite"
eval $cmd
echo " "

echo "### Copying yarn-site.xml "
cmd="cp $origin/$hadoopYarnSite $location/$hadoopYarnSite"
eval $cmd
echo " "

echo "### Copying hadoop's slaves "
cmd="cp $slaves $location/$sparkDir/slaves"
eval $cmd
echo " "

echo "### Copying spark's slaves "
cmd="cp $slaves $location/$hadoopDir/slaves"
eval $cmd
echo " "

# Iterate to the datanodes
for node in `seq $startNode $lastNode`;
do
	echo "scp -qr datanode $nodePrefix$node:~"
	echo "ssh $nodePrefix$node 'cd datanode/ && sudo mv spark $sysDir && sudo mv scala $sysDir && sudo mv hadoop $sysDir"
	echo "ssh $nodePrefix$node 'sudo chown $user -R $sysDir/hadoop && sudo chown $user -R $sysDir/spark && sudo chown $user -R $sysDir/scala"
	echo "ssh $nodePrefix$node 'mv bashrc.templete ~/.bashrc && source ~/.bashrc'"

	scp -r datanode $nodePrefix$node:~
	ssh $nodePrefix$node 'cd ~/datanode/ && sudo mv spark /usr/local && sudo mv scala /usr/local && sudo mv hadoop /usr/local'
	ssh $nodePrefix$node 'sudo chown $user -R /usr/local/hadoop && sudo chown $user -R /usr/local/spark && sudo chown $user -R /usr/local/scala'
	ssh $nodePrefix$node 'mv ~/datanode/bashrc.templete ~/.bashrc && source ~/.bashrc'
	ssh $nodePrefix$node 'rm -Rf ~/datanode'
done

echo "### Deleting masternode and datanode"
# rm -Rf masternode
# rm -Rf datanode






