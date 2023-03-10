#!/usr/bin/env bash
#EricServic.es Lancache Instance
#
# Sourced content as a fork
# https://github.com/lancachenet/monolithic
#
#Installs Customized EricServices Lancache Monolithic Instance
#
###############################################################
# Version 1.1.1
# - Allows for EricServic.es Rocky Linux Repo to be disabled
# - Added colors
# - Fixed prefilled answers
#
Version 1.0.1
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

read -p "Set KIBANA [192.168.1.13]:" KIBANA
KIBANA="${KIBANA:=192.168.1.13}"
echo "$KIBANA"

read -p "Set ELASTICSEARCH [192.168.1.23]:" ELASTICSEARCH
ELASTICSEARCH="${ELASTICSEARCH:=192.168.1.23}"
echo "$ELASTICSEARCH"

###################
# End of Variables
###################


######################
# ElasticSearch Repo #
######################
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


###################
# Old Repo Moving #
###################
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
yum install open-vm-tools curl nginx htop filebeat metricbeat -y 

echo -e "Allow Port 80 for nginx\n"
firewall-cmd --permanent --add-service=http

echo -e "Reload the firewall.\n"
firewall-cmd --reload


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
echo -e "${GREEN}Modify the Metric beat config for Kibana:$KIBANA\n${ENDCOLOR}"
sed -i 's/#host: \"localhost:5601\"/host: \"'"${KIBANA}"':5601\"/' /etc/metricbeat/metricbeat.yml

sed -i 's/hosts: \[\"localhost:9200\"\]/hosts: \[\"'"${ELASTICSEARCH}"':9200\"\]/' /etc/metricbeat/metricbeat.yml

metricbeat modules enable nginx

systemctl enable metricbeat
systemctl restart metricbeat
#systemctl status metricbeat


###################
# FileBeat Config #
###################
echo -e "${GREEN}Modify the Filebeat config for Kibana:$KIBANA\n${ENDCOLOR}"
sed -i 's/#host: \"localhost:5601\"/host: \"'"${KIBANA}"':5601\"/' /etc/filebeat/filebeat.yml

sed -i 's/hosts: \[\"localhost:9200\"\]/hosts: \[\"'"${ELASTICSEARCH}"':9200\"\]/' /etc/filebeat/filebeat.yml

sed -i 's/enabled: false/enabled: true/' /etc/filebeat/filebeat.yml

filebeat modules enable nginx

systemctl enable filebeat
systemctl restart filebeat
#systemctl status filebeat


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
