#!/bin/bash

get_master_info() {
    # Fetch details of the master and parse specific fields
    echo "-------------------------------------"
    echo "Fetching master info..."
    echo "-------------------------------------"
    info=$(redis-cli -h redis-sentinel1 -p 26379 SENTINEL master redismaster)
    echo "IP: $(echo "$info" | awk '/^ip/{getline; print $1}')"
    echo "Port: $(echo "$info" | awk '/^port/{getline; print $1}')"
    echo "Flags: $(echo "$info" | awk '/^flags/{getline; print $1}')"
    echo "Number of Slaves: $(echo "$info" | awk '/^num-slaves/{getline; print $1}')"
}

get_master_replicas_info() {
    # List all replicas of the new master
    redis-cli -h redis-sentinel1 -p 26379 SENTINEL slaves redismaster | grep -E "(name|flags)" -A 1
}

echo "-------------------------------------"
echo "1. Checking current master"
echo "-------------------------------------"
get_master_info

echo "-------------------------------------"
echo "2. Triggering failover"
echo "-------------------------------------"
redis-cli -h redis-sentinel1 -p 26379 SENTINEL failover redismaster
echo "Failover initiated, waiting for completion..."
sleep 10

echo "-------------------------------------"
echo "3. Checking new master after failover"
echo "-------------------------------------"
get_master_info

# Optionally, if you want to check if the old master has become a replica
# and is back online, you can wait for a while and then check the status
# of all replicas. This step is useful if the old master was brought down
# deliberately and then brought back up.

# Give some time for the old master to potentially come back up as a replica
echo "-------------------------------------"
echo "4. Checking the status of all replicas"
echo "-------------------------------------"
sleep 10
get_master_replicas_info
