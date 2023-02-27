# EricServices-Lancache-nginx


Script to automatically install nginx config for a monolithic lancache instance  
Sourced from https://github.com/lancachenet/monolithic

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
ELASTICSEARCH = Define the Elasticsearch Node    

ESREPO = EricServic.es Rocky Linux Repository

CACHE_DISK_SIZE = Define size of cache storage  
CACHE_INDEX_SIZE = Define size of cache index  
CACHE_MAX_AGE = Define age of age  
UPSTREAM_DNS1 = Define nginx upstream DNS server    
UPSTREAM_DNS2 = Define nginx upstream DNS server  

# Customization
Allows for simple inputs to set variables    
Toggle EricServic.es Repository usage    


# Support
[Discord](https://discord.gg/8nKBgURRbW)
