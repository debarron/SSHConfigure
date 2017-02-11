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

DN="datanode"
MN="masternode"

outDN="$DN.tar.gz"
outMN="$MN.tar.gz"

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

# Remove tars
removeDNT="rm $outDN"
removeMNT="rm $outMN"
echo "### Removing the TAR files"
echo "Removing: $removeMNT "
echo "Removing: $removeDNT "
eval $removeMNT
eval $removeDNT
echo " "


# Change the values for the master
location="masternode"
temCS="$location/$hadoopDir/core-site.xml.temp"
temYS="$location/$hadoopDir/yarn-site.xml.temp"
slaves="$location/$hadoopDir/slaves"
echo "### Editin files"
echo "Editing: core-site.xml"
echo "Editing: yarn-site.xml"
echo "Editing: masters"
echo "Editing: slaves "
echo " " > $slaves
for node in `seq $startNode $lastNode`;
do
	echo "$nodePrefix$node" >> $slaves
done
echo " "

coreSiteCmd="$patternCoreSite $location/$hadoopCoreSite > $temCS"
yarnSiteCmd="$patternYarnSite $location/$hadoopYarnSite > $temYS"
cmd="mv $temCS $location/$hadoopCoreSite && mv $temYS $location/$hadoopYarnSite && "
cmd="$cmd echo $serverName > $location/$hadoopMasters && "
cmd="$cmd cp $slaves $location/$sparkDir/"

eval $coreSiteCmd
eval $yarnSiteCmd
eval $cmd
echo " "

cmd="sudo cp -r $location/spark $sysDir/ && sudo cp -r $location/scala $sysDir/ && sudo cp -r $location/hadoop $sysDir/ && "
cmd="$cmd sudo chown $user -R $sysDir/spark && sudo chown $user -R $sysDir/hadoop && sudo chown $user -R $sysDir/scala && "
cmd="$cmd mv $location/bashrc.templete ~/.bashrc && source ~/.bashrc"
echo "### Moving the files to $sysDir"
eval $cmd
echo "### Masternode's files configured "
echo " "
echo " "


location="datanode"
origin="masternode"
echo "### Replicating the changes to datanode"
echo "Copying: core-site.xml"
echo "Copying: yarn-site.xml"
echo "Copying: slaves"
echo "Copying: masters"
cmd="cp $origin/$hadoopCoreSite $location/$hadoopCoreSite && "
cmd="$cmd cp $origin/$hadoopYarnSite $location/$hadoopYarnSite && "
cmd="$cmd cp $slaves $location/$sparkDir/slaves && "
cmd="$cmd cp $slaves $location/$hadoopDir/slaves && "
cmd="$cmd cp $origin/$hadoopMasters $location/$hadoopMasters"
eval $cmd
echo " "

echo "### Configuring remote nodes"
for node in `seq $startNode $lastNode`;
do
	echo "Accesing: $nodePrefix$node"
	cmd="scp -qr datanode $nodePrefix$node:~ && ssh $nodePrefix$node '"
	cmd="$cmd cd ~/datanode/ && sudo mv spark /usr/local && sudo mv scala /usr/local && sudo mv hadoop /usr/local && "
	cmd="$cmd sudo chown $user -R /usr/local/hadoop && sudo chown $user -R /usr/local/spark && sudo chown $user -R /usr/local/scala && "
	cmd="$cmd mv ~/datanode/bashrc.templete ~/.bashrc && "
	cmd="$cmd echo ' ' >> ~/.bashrc && echo 'export JAVA_HOME=/usr/lib/jvm/default-java/' >> ~/.bashrc && source ~/.bashrc && rm -Rf ~/datanode'"
	eval $cmd

done

echo ' ' >> ~/.bashrc && echo 'export JAVA_HOME=/usr/lib/jvm/default-java/' >> ~/.bashrc && source ~/.bashrc 

echo "### Deleting files"
echo "Deleting: masternode "
echo "Deleting: datanode"
rm -Rf masternode
rm -Rf datanode






