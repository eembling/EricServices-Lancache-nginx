#!/usr/bin/env bash
#EricServic.es Lancache Instance
#
# Sourced content as a fork
# https://github.com/lancachenet/monolithic
#
#Installs Customized EricServices Lancache Monolithic Instance
#
###############################################################
# Version 1.3.1
# - Add support for Telegraf
# - Add support for InfluxDB
# - Add toggle for Telegraf/InfluxDB
#
# Version 1.2.1
# - Allow for selection for ELK Stack install
#
# Version 1.1.1
# - Allows for EricServic.es Rocky Linux Repo to be toggled
# - Added colors
# - Fixed prefilled answers
#
# Version 1.0.1
# - Reads in values for variables
# - Installs Elastic Repo
# - Installs Internal Repo (if enabled)
# - Installs required packages
# - Opens port 80 / tcp
# - Download Nginx files
# - Create /var/data/cache directory
# - Modify nginx configs
# - set to permissive
# - Modify filebeat.yml
# - Modify metricbeat.yml
# - Start nginx
# - Ask to reboot
################################################################

##### Variables ###############################
# CACHE_DISK_SIZE - total disk size for cache
# CACHE_INDEX_SIZE - Index side, 250MB = 1TB storage
# CACHE_MAX_AGE - How long to store the cache
# UPSTREAM_DNS - Valid DNS without lancache-dns replies
# KIBABA - Kibana IP Address
# ELASTICSEARCH - Elasticsearch IP Address
# INFLUX_TOKEN - InfluxDB Access Token
###############################################

#################
# Define Colors #
#################
RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
ENDCOLOR="\e[0m"


echo -e "${GREEN}EricServic.es Lancache Server Build${ENDCOLOR}"

echo -e "${BLUE} ______      _       _____                 _                   _                  _____           _      ${ENDCOLOR}"  
echo -e "${BLUE}|  ____|    (_)     / ____|               (_)                 | |                / ____|         | |         ${ENDCOLOR}"
echo -e "${BLUE}| |__   _ __ _  ___| (___   ___ _ ____   ___  ___   ___  ___  | |     __ _ _ __ | |     __ _  ___| |__   ___ ${ENDCOLOR}"
echo -e "${BLUE}|  __| | '__| |/ __|\___ \ / _ \ '__\ \ / / |/ __| / _ \/ __| | |    / _' | '_ \| |    / _' |/ __| '_ \ / _ \ ${ENDCOLOR}"
echo -e "${BLUE}| |____| |  | | (__ ____) |  __/ |   \ V /| | (__ |  __/\__ \ | |___| (_| | | | | |___| (_| | (__| | | |  __/${ENDCOLOR}"
echo -e "${BLUE}|______|_|  |_|\___|_____/ \___|_|    \_/ |_|\___(_)___||___/ |______\__,_|_| |_|\_____\__,_|\___|_| |_|\___|\n${ENDCOLOR}"


#####################
# Set all Variables #
#####################
echo -e "${GREEN}Set Variables for custom install.${ENDCOLOR}"

read -p "Use EricServic.es Repository [y/N]:" ESREPO
ESREPO="${ESREPO:=n}"
echo "$ESREPO"

read -p "Set CACHE_DISK_SIZE [950000m]:" CACHE_DISK_SIZE
CACHE_DISK_SIZE="${CACHE_DISK_SIZE:=950000m}"
echo "$CACHE_DISK_SIZE"

read -p "Set CACHE_INDEX_SIZE [250m]:" CACHE_INDEX_SIZE
CACHE_INDEX_SIZE="${CACHE_INDEX_SIZE:=250m}"
echo "$CACHE_INDEX_SIZE"

read -p "Set CACHE_MAX_AGE [3650d]:" CACHE_MAX_AGE
CACHE_MAX_AGE="${CACHE_MAX_AGE:=3650d}"
echo "$CACHE_MAX_AGE"

read -p "Set UPSTREAM_DNS1 [8.8.8.8]:" UPSTREAM_DNS1
UPSTREAM_DNS1="${UPSTREAM_DNS1:=8.8.8.8}"
echo "$UPSTREAM_DNS1"

read -p "Set UPSTREAM_DNS2 [8.8.4.4]:" UPSTREAM_DNS2
UPSTREAM_DNS="${UPSTREAM_DNS2:=8.8.4.4}"
echo "$UPSTREAM_DNS2"

read -p "Configure GEOIP [y/N]:" GEOIP
GEOIP="${GEOIP:=n}"
echo "$GEOIP"

if [[ "$GEOIP" =~ ^([yY][eE][sS]|[yY])$ ]]
then
	read -p "Set GeoIP Account Number [0]:" GEOIPACCT
	GEOIPACCT="${GEOIPACCT:=0}"
	echo "$GEOIPACCT"
	
	read -p "Set GeoIP Key [0000000000]:" GEOIPKEY
	GEOIPKEY="${GEOIPKEY:=00000000}"
	echo "$GEOIPKEY"
fi

read -p "Configure Local ELK Stack [y/N]:" ELK
ELK="${ELK:=n}"
echo "$ELK"

if [[ "$ELK" =~ ^([yY][eE][sS]|[yY])$ ]]
then
	read -p "Set KIBANA [192.168.1.13]:" KIBANA
	KIBANA="${KIBANA:=192.168.1.13}"
	echo "$KIBANA"

	read -p "Set ELASTICSEARCH [192.168.1.23]:" ELASTICSEARCH
	ELASTICSEARCH="${ELASTICSEARCH:=192.168.1.23}"
	echo "$ELASTICSEARCH"
fi

read -p "Configure Telegraf/InfluxDB  [y/N]:" TELGRAF
TELGRAF="${TELGRAF:=n}"
echo "$TELGRAF"

if [[ "$TELEGRAF" =~ ^([yY][eE][sS]|[yY])$ ]]
then
	read -p "Set InfluxDB [127.0.0.1]:" INFLUXDB
	INFLUXDB="${INFLUXDB:=127.0.0.1}"
	echo "$INFLUXDB"
 
	read -p "Set InfluxDB Access Token [********]:" INFLUX_TOKEN
	INFLUX_TOKEN="${INFLUX_TOKEN:=********}"
	echo "$INFLUX_TOKEN"
fi

###################
# End of Variables
###################


######################
# ElasticSearch Repo #
######################
if [[ "$ELK" =~ ^([yY][eE][sS]|[yY])$ ]]
then
	echo -e "${GREEN}\nConfigure the Elasticsearch Repository.${ENDCOLOR}"
	sleep 1

	ELASTICSEARCH_FILE=/etc/yum.repos.d/elasticsearch.repo
	if test -f "$ELASTICSEARCH_FILE"; then
    		echo -e "$ELASTICSEARCH_FILE already exists, no need to create.\n"
	fi

	if [ ! -f "$ELASTICSEARCH_FILE" ]
	then 
		echo -e "$ELASTICSEARCH_FILE does not exist, creating it.\n"
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
fi


#################
# Telegraf Repo #
#################
if [[ "$TELEGRAF" =~ ^([yY][eE][sS]|[yY])$ ]]
then
	echo -e "${GREEN}\nConfigure the Telegraf Repository.${ENDCOLOR}"
	sleep 1

	TELEGRAF_FILE=/etc/yum.repos.d/influxdb.repo
	if test -f "$TELEGRAF_FILE"; then
    		echo -e "$TELEGRAF_FILE already exists, no need to create.\n"
	fi

	if [ ! -f "$TELGRAF_FILE" ]
	then 
		echo -e "$TELEGRAF_FILE does not exist, creating it.\n"
		cat << EOF >> /etc/yum.repos.d/influxdb.repo
                [influxdb]
                name = InfluxData Repository - Stable
                baseurl = https://repos.influxdata.com/stable/\$basearch/main
                enabled = 1
                gpgcheck = 1
                gpgkey = https://repos.influxdata.com/influxdata-archive_compat.key
                EOF
	fi
fi

############################
# Local EricServic.es Repo #
############################
if [[ "$ESREPO" =~ ^([yY][eE][sS]|[yY])$ ]]
then
	echo -e "${GREEN}Configure the EricServic.es Local Repository.\n${ENDCOLOR}"
	sleep 1

	LOCALREPO_FILE=/etc/yum.repos.d/localrepo.repo
	if test -f "$LOCALREPO_FILE"; then
    		echo -e "$LOCALREPO_FILE already exists, no need to create.\n"
	fi

	if [ ! -f "$LOCALREPO_FILE" ]
	then 
		echo -e "$LOCALREPO_FILE does not exist, creating it.\n"
		cat << EOF >> /etc/yum.repos.d/localrepo.repo
		[localrepo-base]
		name= Local RockyLinux BaseOS
		baseurl=http://mirror.ericembling.me/rocky-linux/\$releasever/BaseOS/\$basearch/os/
		gpgcheck=0
		enabled=1
		[localrepo-appstream]
		name=Local RockyLinux AppStream
		baseurl=http://mirror.ericembling.me/rocky-linux/\$releasever/AppStream/\$basearch/os/
		gpgcheck=0
		enabled=1
		EOF
	fi
fi
###################
# Old Repo Moving #
###################
if [[ "$ESREPO" =~ ^([yY][eE][sS]|[yY])$ ]]
then
	echo -e "${GREEN}Move old Rocky Linux Repos so they are not used.\n${ENDCOLOR}"
	sleep 1

	ROCKYBASEOS_FILE=/etc/yum.repos.d/Rocky-BaseOS.repo.old
	ROCKYAPPSTREAM_FILE=/etc/yum.repos.d/Rocky-AppStream.repo.old
	if test -f "$ROCKYBASEOS_FILE"; then
    		echo -e "$ROCKYBASEOS_FILE already exists, no need to move.\n"
	fi

	if [ ! -f "$ROCKYBASEOS_FILE" ]
	then 
		mv /etc/yum.repos.d/Rocky-BaseOS.repo /etc/yum.repos.d/Rocky-BaseOS.repo.old
	fi

	if test -f "$ROCKYAPPSTREAM_FILE"; then
    		echo -e "$ROCKYAPPSTREAM_FILE already exists, no need to move.\n"
	fi

	if [ ! -f "$ROCKYAPPSTREAM_FILE" ]
	then 
		mv /etc/yum.repos.d/Rocky-AppStream.repo /etc/yum.repos.d/Rocky-AppStream.repo.old
	fi

fi

################################
# Updates + Install + Firewall #
################################
echo -e "${GREEN}Process updates and install\n${ENDCOLOR}"
sleep 1

echo -e "run yum update\n"
yum update -y

echo -e "Install epel-release\n"
yum install epel-release -y

echo -e "Check to see if required programs are installed.\n"
yum install open-vm-tools curl nginx htop  -y 

if [[ "$GEOIP" =~ ^([yY][eE][sS]|[yY])$ ]]
then
	echo -e "Install GeoIP\n"
	yum install geoip geoipupdate -y
fi

if [[ "$ELK" =~ ^([yY][eE][sS]|[yY])$ ]]
then
	echo -e "Install ELK applications.\n"
	yum install filebeat metricbeat -y
fi

if [[ "$TELEGRAF" =~ ^([yY][eE][sS]|[yY])$ ]]
then
	echo -e "Install Telegraf\n"
	yum install telegraf influxdb2 -y
fi

echo -e "Allow Port 80 for nginx\n"
firewall-cmd --permanent --add-service=http

if [[ "$TELEGRAF" =~ ^([yY][eE][sS]|[yY])$ ]]
then
	echo -e "Allow port 8086 for InfluxDB\n"
	firewall-cmd --permanent --add-port=8086/tcp
fi

echo -e "Reload the firewall.\n"
firewall-cmd --reload
firewall-cmd --list-ports

#######################
# Nginx File Download #
#######################
echo -e "${GREEN}Download required nginx config files.\n${ENDCOLOR}"
sleep 1

echo -e "Check to see if nginx.conf.old file exists already.\n"
NGINXOLD_FILE=/etc/nginx/nginx.conf.old
if test -f "$NGINXOLD_FILE"; then
    echo -e "$NGINXOLD_FILE already exists, need to delete.\n"
    rm /etc/nginx/nginx.conf.old
fi

echo -e "Check to see if nginx.conf file exists already.\n"
NGINX_FILE=/etc/nginx/nginx.conf
if test -f "$NGINX_FILE"; then
    echo -e "$NGINX_FILE already exists, needs to be moved.\n"
    mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.old
fi

echo -e "Make sure no nginx.conf file exists now, and download it.\n"
if [ ! -f "$NGINX_FILE" ]
then
	curl -o /etc/nginx/nginx.conf https://raw.githubusercontent.com/eembling/EricServices-Lancache-nginx/main/nginx.conf
fi

echo -e "Download the cache key if it does not exist.\n"
CACHEKEY_FILE=/etc/nginx/conf.d/20_proxy_cache_path.conf
if [ ! -f "$CACHEKEY_FILE" ]
then
	curl -o /etc/nginx/conf.d/20_proxy_cache_path.conf https://raw.githubusercontent.com/eembling/EricServices-Lancache-nginx/main/20_proxy_cache_path.conf
fi

echo -e "Download the maps if it does not exist.\n"
MAPS_FILE=/etc/nginx/conf.d/30_maps.conf
if [ ! -f "$MAPS_FILE" ]
then
	curl -o /etc/nginx/conf.d/30_maps.conf https://raw.githubusercontent.com/eembling/EricServices-Lancache-nginx/main/30_maps.conf
fi

################################
# Building the Cache Directory #
################################
echo -e "${GREEN}Building the Cache Directory\n${ENDCOLOR}"
sleep 1

CACHEDIR=/var/data/cache
if [ -d "$CACHEDIR" ];
then
	echo -e "Cache directory already created, no need to build.\n"
fi

if [ ! -d "$CACHEDIR" ];
then
	echo -e "Creating required cache directory.\n"
	mkdir /var/data
	chmod 755 /var/data
	chown nginx:nginx /var/data
	mkdir /var/data/cache
	chmod 755 /var/data/cache
	chown nginx:nginx /var/data/cache
fi

##########################
# Set to Permissive Mode #
# Requires reboot        #
##########################
echo -e "${GREEN}Setting Permissive SELINUX value.\n${ENDCOLOR}"
sed -i 's/SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config

################
# Nginx Config #
################
echo -e "${GREEN}Setting the Upstream DNS values\n${ENDCOLOR}"
sed -i 's/resolver .* ipv6=off;/resolver '"${UPSTREAM_DNS1}"' '"${UPSTREAM_DNS2}"' ipv6=off;/' /etc/nginx/nginx.conf

sed -i 's/keys_zone=generic:[0-9]*m inactive/keys_zone=generic:'"${CACHE_INDEX_SIZE}"' inactive/' /etc/nginx/conf.d/20_proxy_cache_path.conf
sed -i 's/inactive=[0-9]*d max_size/inactive='"${CACHE_MAX_AGE}"' max_size/' /etc/nginx/conf.d/20_proxy_cache_path.conf
sed -i 's/max_size=[0-9]*m loader_files/max_size='"${CACHE_DISK_SIZE}"' loader_files/' /etc/nginx/conf.d/20_proxy_cache_path.conf


##################
# Starting Nginx #
##################
echo -e "${GREEN}Starting up nginx\n${ENDCOLOR}"
sleep 1

systemctl enable nginx
systemctl restart nginx
#systemctl status nginx


#####################
# MetricBeat Config #
#####################
if [[ "$ELK" =~ ^([yY][eE][sS]|[yY])$ ]]
then
	echo -e "${GREEN}Modify the Metric beat config for Kibana:$KIBANA\n${ENDCOLOR}"
	sed -i 's/#host: \"localhost:5601\"/host: \"'"${KIBANA}"':5601\"/' /etc/metricbeat/metricbeat.yml
	sed -i 's/hosts: \[\"localhost:9200\"\]/hosts: \[\"'"${ELASTICSEARCH}"':9200\"\]/' /etc/metricbeat/metricbeat.yml

	metricbeat modules enable nginx

	systemctl enable metricbeat
	systemctl restart metricbeat
	#systemctl status metricbeat
fi

###################
# FileBeat Config #
###################
if [[ "$ELK" =~ ^([yY][eE][sS]|[yY])$ ]]
then
	echo -e "${GREEN}Modify the Filebeat config for Kibana:$KIBANA\n${ENDCOLOR}"
	sed -i 's/#host: \"localhost:5601\"/host: \"'"${KIBANA}"':5601\"/' /etc/filebeat/filebeat.yml
	sed -i 's/hosts: \[\"localhost:9200\"\]/hosts: \[\"'"${ELASTICSEARCH}"':9200\"\]/' /etc/filebeat/filebeat.yml
	sed -i 's/enabled: false/enabled: true/' /etc/filebeat/filebeat.yml

	filebeat modules enable nginx

	systemctl enable filebeat
	systemctl restart filebeat
	#systemctl status filebeat
fi

###################
# Telegraf Config #
###################
if [[ "$TELEGRAF" =~ ^([yY][eE][sS]|[yY])$ ]]
then
	echo -e "${GREEN}Configure Telegraf\n${ENDCOLOR}"
	TELEGRAF_FILE=/etc/telegraf/telegraf.conf
	if [ ! -f "$TELEGRAF_FILE" ]
	then
		curl -o /etc/telegraf/telegraf.conf https://raw.githubusercontent.com/eembling/EricServices-Lancache-nginx/dev/telegraf.conf
	fi

 	systemctl enable telegraf
  	systemctl restart telegraf
   	#systemctl status telegraf
fi


##########
# Reboot #
##########
read -p "Would you like to reboot?[y/N]:" REBOOT
REBOOT="${REBOOT:=n}"
if [[ "$REBOOT" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    echo -e "Rebooting to allow for Open-VM-Tools and Permissive Mode.\n"
    sleep 5
    shutdown -r now
fi
