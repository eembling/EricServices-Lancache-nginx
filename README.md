# EricServices-Lancache-nginx


Script to automatically install nginx config for a monolithic lancache instance  

Allows for quick spin-up outside of Docker  
Allows for Filebeat and Metricbeat Install and Configuration  

# Dependencies  
- Rocky Linux, Redhat, Fedora, or CentOS

# Installation  
## Live (Read the Code first!)  
    bash <(curl -s https://raw.githubusercontent.com/eembling/EricServices-Lancache-nginx/main/lancache.sh)  

## Manual:  
    cd /opt  
    wget https://raw.githubusercontent.com/eembling/EricServices-Lancache-nginx/main/lancache.sh
    chmod +x lancache.sh
    ./lancache.sh  

# Variables 
KIBANA = Define the Kibana Host  
ELASTICSEARCH1 = Define the Elasticsearch Node    
ELASTICSEARCH2 = Define the Elasticsearch Node    

CACHE_DISK_SIZE = Define size of cache storage  
CACHE_INDEX_SIZE = Define size of cache index  
CACHE_MAX_AGE = Define age of age  
UPSTREAM_DNS1 = Define nginx upstream DNS server    
UPSTREAM_DNS2 = Define nginx upstream DNS server    

# Support
[Discord](https://discord.gg/8nKBgURRbW)
