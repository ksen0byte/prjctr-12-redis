#!/bin/bash

source ./utils.sh

REDIS_MAXMEMORY="4mb"
EVICTION_POLICY="noeviction"

echo "-------------------------------------"
echo "Demonstrating the $EVICTION_POLICY policy in Redis..."
echo "-------------------------------------"

redis_flush_db
redis_set_max_memory $REDIS_MAXMEMORY
redis_set_eviction_policy $EVICTION_POLICY

# Function to add data until Redis runs out of memory
add_data_until_full() {
    i=1
    while true; do
        local data=$(generate_random_data 1) # 1KB
        output=$(redis-cli -h redis-master -p 6379 SET "key$i" "$data" 2>&1)
        if [[ $output == *"OOM"* ]]; then
            echo "Out of memory error returned after $i writes."
            break
        fi
        ((i++))
    done
}

# Add data to Redis
echo "-------------------------------------"
echo "Adding data to Redis..."
echo "-------------------------------------"
add_data_until_full

echo "-------------------------------------"
echo "Getting DBSIZE from Redis..."
echo "-------------------------------------"
redis-cli -h redis-master -p 6379 DBSIZE

echo "-------------------------------------"
echo "Demonstration complete."
echo "-------------------------------------"
