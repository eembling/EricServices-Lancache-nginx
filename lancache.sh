#!/usr/bin/env bash
#EricServic.es Lancache Instance
#
#Installs Customized EricServices Lancache Monolithic Instance
#
# Version 1.0.1
#
##### Variables #####
echo "EricServic.es Lancache Server Build"


 echo " ______      _       _____                 _                   _                  _____           _      "  
 echo "|  ____|    (_)     / ____|               (_)                 | |                / ____|         | |         "
 echo "| |__   _ __ _  ___| (___   ___ _ ____   ___  ___   ___  ___  | |     __ _ _ __ | |     __ _  ___| |__   ___ "
 echo "|  __| | '__| |/ __|\___ \ / _ \ '__\ \ / / |/ __| / _ \/ __| | |    / _' | '_ \| |    / _' |/ __| '_ \ / _ \ "
 echo "| |____| |  | | (__ ____) |  __/ |   \ V /| | (__ |  __/\__ \ | |___| (_| | | | | |___| (_| | (__| | | |  __/"
 echo "|______|_|  |_|\___|_____/ \___|_|    \_/ |_|\___(_)___||___/ |______\__,_|_| |_|\_____\__,_|\___|_| |_|\___|"


ELASTICSEARCH_FILE=/etc/yum.repos.d/elasticsearch.repo
if test -f "$ELASTICSEARCH_FILE"; then
    echo "$ELASTICSEARCH_FILE already exists, no need to create."
fi

if [ ! -f "$ELASTICSEARCH_FILE" ]
	then 
	echo "$ELASTICSEARCH_FILE does not exist, creating it."
   	cat << EOF >> /etc/yum.repos.d/elasticsearch.repo
	[elasticsearch]
	name=Elasticsearch repository for 7.x packages
	baseurl=https://artifacts.elastic.co/packages/7.x/yum
	gpgcheck=1
	gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
	enabled=1
	autorefresh=1
	type=rpm-md
EOF
fi
echo "end of test"


LOCALREPO_FILE=/etc/yum.repos.d/localrepo.repo
if test -f "$LOCALREPO_FILE"; then
    echo "$LOCALREPO_FILE already exists, no need to create."
fi

if [ ! -f "$LOCALREPO_FILE" ]
	then 
	echo "$LOCALREPO_FILE does not exist, creating it."
   	cat << EOF >> /etc/yum.repos.d/elasticsearch.repo
	[localrepo-base]
	name= Local RockyLinux BaseOS
	baseurl=http://mirror.ericembling.me/rocky-linux/$releasever/BaseOS/$basearch/os/
	gpgcheck=0
	enabled=1

	[localrepo-appstream]
	name=Local RockyLinux AppStream
	baseurl=http://mirror.ericembling.me/rocky-linux/$releasever/AppStream/$basearch/os/
	gpgcheck=0
	enabled=1
EOF
fi

echo "end of test"
