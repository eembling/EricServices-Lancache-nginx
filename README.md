# EricServices-Lancache-nginx


Script to automatically install nginx config for a monolithic lancache instance  

Allows for quick spin-up outside of Docker  
Allows for Filebeat and Metricbeat Install and Configuration  

# Dependencies  
- Rocky Linux or CentOS linux  

# Installation  
## Live (Read the Code first!)  
      bash <(curl -s hhttps://raw.githubusercontent.com/eembling/EricServices-Lancache-nginx/main/lancache.sh)  

## Manual:  
      cd /opt  
      wget -O - https://raw.githubusercontent.com/eembling/EricServices-Lancache-nginx/main/lancache.sh
      chmod +x lancache.sh
      ./lancache.sh  

# Variables 
KIBANA = Define the Kibana Host  
ELASTICSEARCH = Define the Elasticsearch Nodes (comma seperated)     

CACHE_DISK_SIZE = Define size of cache storage  
CACHE_INDEX_SIZE = Define size of cache index  
CACHE_MAX_AGE = Define age of age  
UPSTREAM_DNS = Define nginx upstream DNS server (comma seperated)    

# Support
[Discord](https://discord.gg/8nKBgURRbW)
