#!/bin/bash
set -euo pipefail

source ./utils.sh

KEY_SIZE_KB=10
INIT_KEY_NUM=${1:-100}
EVICTION_KEY_NUM=${2:-200}
REDIS_MAXMEMORY="4mb"
EVICTION_POLICY="allkeys-lru"

echo "-------------------------------------"
echo "Demonstrating the $EVICTION_POLICY eviction policy in Redis..."
echo "-------------------------------------"

redis_flush_db
redis_set_max_memory $REDIS_MAXMEMORY
redis_set_eviction_policy $EVICTION_POLICY

redis_add_data "init" $INIT_KEY_NUM $KEY_SIZE_KB 

redis_check_memory_usage

# Access some keys to change their LRU status
redis_get_keys "init" $INIT_KEY_NUM

redis_add_data "trigger" $EVICTION_KEY_NUM $KEY_SIZE_KB

redis_check_memory_usage

# Check which keys were evicted
echo "-------------------------------------"
echo "Verifying which keys were evicted..."
echo "-------------------------------------"
declare -A prefix_key_map
prefix_key_map["init"]=$INIT_KEY_NUM
prefix_key_map["trigger"]=$EVICTION_KEY_NUM
redis_keys_exist prefix_key_map

echo "-------------------------------------"
echo "Demonstration complete."
echo "-------------------------------------"
