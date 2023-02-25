#!/usr/bin/env bash
#EricServic.es Lancache Instance
#
#Installs Customized EricServices Lancache Monolithic Instance
#
###############################################
# Version 1.0.1
# - Reads in values for variables
# - Installs Elastic Repo
# - Installs Internal Repo
# - Installs required packages
# - Opens port 80 / tcp
# - Download Nginx files
# - Create /var/data/cache directory
# - Start nginx
###############################################
# Left to build
# - Modify nginx.conf
# - Modify filebeat.yaml
# - Modify metricbeat.yaml
##### Variables ###############################
# CACHE_DISK_SIZE - total disk size for cache
# CACHE_INDEX_SIZE - Index side, 250MB = 1TB storage
# CACHE_MAX_AGE - How long to store the cache
# UPSTREAM_DNS - Valid DNS without lancache-dns replies
# KIBABA - Kibana IP Address
# ELASTICSEARCH - Elasticsearch IP Address
###############################################
echo -e "EricServic.es Lancache Server Build\n"


 echo " ______      _       _____                 _                   _                  _____           _      "  
 echo "|  ____|    (_)     / ____|               (_)                 | |                / ____|         | |         "
 echo "| |__   _ __ _  ___| (___   ___ _ ____   ___  ___   ___  ___  | |     __ _ _ __ | |     __ _  ___| |__   ___ "
 echo "|  __| | '__| |/ __|\___ \ / _ \ '__\ \ / / |/ __| / _ \/ __| | |    / _' | '_ \| |    / _' |/ __| '_ \ / _ \ "
 echo "| |____| |  | | (__ ____) |  __/ |   \ V /| | (__ |  __/\__ \ | |___| (_| | | | | |___| (_| | (__| | | |  __/"
 echo "|______|_|  |_|\___|_____/ \___|_|    \_/ |_|\___(_)___||___/ |______\__,_|_| |_|\_____\__,_|\___|_| |_|\___|"



echo -e "Check for Input.\n"
read -p "Set CACHE_DISK_SIZE [900000m]:" CACHE_DISK_SIZE
CACHE_DISK_SIZE="${CACHE_DISK_SIZE:=900000m}"
echo "$CACHE_DISK_SIZE"

read -p "Set CACHE_INDEX_SIZE [500m]:" CACHE_INDEX_SIZE
CACHE_INDEX_SIZE="${CACHE_INDEX_SIZE:=500m}"
echo "$CACHE_INDEX_SIZE"

read -p "Set CACHE_MAX_AGE [3650d]:" CACHE_MAX_AGE
CACHE_MAX_AGE="${CCACHE_MAX_AGE:=3650d}"
echo "$CACHE_MAX_AGE"

read -p "Set UPSTREAM_DNS [8.8.8.8]:" UPSTREAM_DNS
UPSTREAM_DNS="${UPSTREAM_DNS:=8.8.8.8}"
echo "$UPSTREAM_DNS"

read -p "Set KIBANA [192.168.1.10]:" KIBANA
KIBANA="${KIBANA:=192.168.1.10}"
echo "$KIBANA"

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

echo -e "Move old Repos so they are not used.\n"

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


echo -e "Run Yum Update\n"
yum update -y

echo -e "Install epel-release\n"
yum install epel-release -y

echo -e "Check to see if required programs are installed.\n"
yum install open-vm-tools curl nginx htop filebeat metricbeat -y 

echo -e "Allow Port 80 for nginx/n"
firewall-cmd --permanent --add-port=80/tcp

echo -e "Reload the firewall./n"
firewall-cmd --reload

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

CACHEDIR=/var/data/cache
if [ -d "$CACHEDIR" ];
then
echo -e "Directory already created, no need to build.\n"
fi

if [ ! -d "$CACHEDIR" ];
then
mkdir /var/data
chmod 755 /var/data
chown nginx:nginx /var/data
mkdir /var/data/cache
chmod 755 /var/data/cache
chown nginx:nginx /var/data/cache
fi

systemctl enable nginx
systemctl restart nginx

systemctl status nginx

echo -e "Rebooting to allow for Open-VM-Tools and Permissive Mode.\n"
sleep 5
shutdown -h now


echo -e "end of test\n"
